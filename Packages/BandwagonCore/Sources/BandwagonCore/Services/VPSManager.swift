import Foundation
import Observation
import BandwagonAPI

/// 管理单台 VPS 的实时状态与所有后端操作
@Observable
public final class VPSManager: @unchecked Sendable, Identifiable {
    public var id: UUID { account.id }
    public let account: VPSAccount
    public let client: BWGClient

    // 数据缓存
    public var serviceInfo: BWGServiceInfo?
    public var liveInfo: BWGLiveServiceInfo?
    public var snapshots: [BWGSnapshotItem] = []
    public var migrationLocations: BWGMigrationLocationsResponse?
    public var availableOS: BWGAvailableOS?
    public var auditLogs: [BWGAuditLogItem] = []
    public var diskIO: BWGDiskIO?
    public var rateLimitStatus: BWGRateLimitStatus?
    public var sshKeys: [BWGSshKeyItem] = []

    // 运行状态
    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var isPerformingAction: Bool = false
    public var actionFeedbackMessage: String?
    public var lastUpdated: Date?
    public var errorMessage: String?

    public init(account: VPSAccount, apiKey: String) {
        self.account = account
        self.client = BWGClient(veid: account.veid, apiKey: apiKey)
    }

    // MARK: - Computed Properties

    public var isRunning: Bool {
        liveInfo?.isRunning ?? false
    }

    public var ipAddress: String {
        serviceInfo?.primaryIP ?? "—"
    }

    public var sshPort: Int {
        account.customSSHPort ?? liveInfo?.sshPort ?? serviceInfo?.sshPort ?? 22
    }

    public var nodeLocation: String {
        serviceInfo?.nodeLocation ?? "—"
    }

    public var osName: String {
        serviceInfo?.os ?? "—"
    }

    public var hostname: String {
        liveInfo?.liveHostname ?? serviceInfo?.hostname ?? "—"
    }

    public var cpuUsageDescription: String {
        guard let live = liveInfo else { return "—" }
        let averages = live.loadAverages
        if !averages.isEmpty {
            let parts = averages.prefix(3).map { String(format: "%.2f", $0) }
            return parts.joined(separator: " · ")
        } else if let load = live.load1Min {
            return String(format: "%.2f", load)
        }
        return "—"
    }

    public var cpuUsagePercentage: Double {
        guard let load = liveInfo?.load1Min else { return 0.0 }
        // 归一化 CPU 负载，以 2.0 作为 2 核基准归一化并限制在 0.0 ~ 1.0
        return min(max(load / 2.0, 0.0), 1.0)
    }

    public var isCpuThrottled: Bool {
        liveInfo?.isCpuThrottled == 1
    }

    public var memoryTotalBytes: Int64? {
        liveInfo?.memoryTotalBytes ?? serviceInfo?.planRam
    }

    public var memoryUsedBytes: Int64? {
        if let used = liveInfo?.memUsedBytes {
            return used
        }
        if let total = memoryTotalBytes, let avail = liveInfo?.memAvailableBytes {
            return max(0, total - avail)
        }
        return nil
    }

    public var memoryUsagePercentage: Double {
        if let used = memoryUsedBytes, let total = memoryTotalBytes, total > 0 {
            return min(max(Double(used) / Double(total), 0.0), 1.0)
        }
        return liveInfo?.memoryUsedPercentage ?? 0.0
    }

    public var memoryUsageDescription: String {
        guard let used = memoryUsedBytes, let total = memoryTotalBytes else { return "—" }
        return "\(ByteCountFormatter.string(fromByteCount: used, countStyle: .binary)) / \(ByteCountFormatter.string(fromByteCount: total, countStyle: .binary))"
    }

    public var diskTotalBytes: Int64? {
        liveInfo?.diskTotalBytes ?? serviceInfo?.planDisk
    }

    public var diskUsedBytes: Int64? {
        liveInfo?.diskUsedBytes
    }

    public var diskUsagePercentage: Double {
        if let used = diskUsedBytes, let total = diskTotalBytes, total > 0 {
            return min(max(Double(used) / Double(total), 0.0), 1.0)
        }
        return liveInfo?.diskUsedPercentage ?? 0.0
    }

    public var diskUsageDescription: String {
        guard let used = diskUsedBytes, let total = diskTotalBytes else { return "—" }
        return "\(ByteCountFormatter.string(fromByteCount: used, countStyle: .file)) / \(ByteCountFormatter.string(fromByteCount: total, countStyle: .file))"
    }

    public var bandwidthUsagePercentage: Double {
        serviceInfo?.bandwidthUsedPercentage ?? 0.0
    }

    public var bandwidthUsageDescription: String {
        guard let used = serviceInfo?.dataCounter, let total = serviceInfo?.planMonthlyData else { return "—" }
        return "\(ByteCountFormatter.string(fromByteCount: used, countStyle: .file)) / \(ByteCountFormatter.string(fromByteCount: total, countStyle: .file))"
    }

    // MARK: - Data Fetching

    @MainActor
    public func refreshAll() async {
        if serviceInfo == nil {
            isLoading = true
        } else {
            isRefreshing = true
        }
        errorMessage = nil

        do {
            async let serviceInfoTask = client.getServiceInfo()
            async let liveInfoTask = client.getLiveServiceInfo()

            let (service, live) = try await (serviceInfoTask, liveInfoTask)
            self.serviceInfo = service
            self.liveInfo = live
            self.lastUpdated = Date()
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
        isRefreshing = false
    }

    @MainActor
    public func refreshLiveInfo() async {
        do {
            let live = try await client.getLiveServiceInfo()
            self.liveInfo = live
            self.lastUpdated = Date()
        } catch {
            // 静默更新 live 状态时不重置已有数据
            print("Failed to refresh live info: \(error)")
        }
    }

    @MainActor
    public func loadSnapshots() async {
        do {
            let res = try await client.listSnapshots()
            self.snapshots = res.snapshots ?? []
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func loadMigrationLocations() async {
        do {
            let res = try await client.getMigrationLocations()
            self.migrationLocations = res
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func loadAvailableOS() async {
        do {
            let res = try await client.getAvailableOS()
            self.availableOS = res
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func loadAuditLogs() async {
        do {
            let res = try await client.getAuditLog()
            self.auditLogs = res.log ?? []
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func loadDiskIO() async {
        do {
            let res = try await client.getDiskIO()
            self.diskIO = res
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func loadRateLimitStatus() async {
        do {
            let res = try await client.getRateLimitStatus()
            self.rateLimitStatus = res
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func loadSshKeys() async {
        do {
            let res = try await client.getSshKeys()
            self.sshKeys = res.keys ?? []
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Actions

    @MainActor
    private func executeAction(name: String, _ block: () async throws -> BWGAPIResponse) async {
        isPerformingAction = true
        errorMessage = nil
        actionFeedbackMessage = nil

        do {
            let response = try await block()
            if response.isSuccess {
                actionFeedbackMessage = "\(name) executed successfully."
                // 稍后刷新状态
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await refreshAll()
            } else {
                errorMessage = response.message ?? "Action failed."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPerformingAction = false
    }

    @MainActor
    public func start() async {
        await executeAction(name: "Start") {
            try await client.start()
        }
    }

    @MainActor
    public func stop() async {
        await executeAction(name: "Stop") {
            try await client.stop()
        }
    }

    @MainActor
    public func restart() async {
        await executeAction(name: "Restart") {
            try await client.restart()
        }
    }

    @MainActor
    public func forceStop() async {
        await executeAction(name: "Force Stop") {
            try await client.kill()
        }
    }

    @MainActor
    public func createSnapshot(description: String? = nil) async {
        await executeAction(name: "Create Snapshot") {
            try await client.createSnapshot(description: description)
        }
        await loadSnapshots()
    }

    @MainActor
    public func deleteSnapshot(key: String) async {
        await executeAction(name: "Delete Snapshot") {
            try await client.deleteSnapshot(key: key)
        }
        await loadSnapshots()
    }

    @MainActor
    public func restoreSnapshot(key: String) async {
        await executeAction(name: "Restore Snapshot") {
            try await client.restoreSnapshot(key: key)
        }
    }

    @MainActor
    public func startMigration(to location: String) async {
        await executeAction(name: "Migration") {
            try await client.startMigration(location: location)
        }
    }

    @MainActor
    public func reinstallOS(to template: String) async {
        await executeAction(name: "Reinstall OS") {
            try await client.reinstallOS(os: template)
        }
    }

    @MainActor
    public func resetRootPassword() async {
        await executeAction(name: "Reset Root Password") {
            try await client.resetRootPassword()
        }
    }

    @MainActor
    public func setHostname(_ newHostname: String) async {
        await executeAction(name: "Set Hostname") {
            try await client.setHostname(newHostname)
        }
    }

    @MainActor
    public func setPTR(ip: String, ptr: String) async {
        await executeAction(name: "Set PTR") {
            try await client.setPTR(ip: ip, ptr: ptr)
        }
    }

    @MainActor
    public func addIPv6() async {
        await executeAction(name: "Add IPv6") {
            try await client.addIPv6()
        }
    }

    @MainActor
    public func deleteIPv6(ip: String) async {
        await executeAction(name: "Delete IPv6") {
            try await client.deleteIPv6(ip: ip)
        }
    }
}
