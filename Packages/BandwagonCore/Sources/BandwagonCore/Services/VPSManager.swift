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
        account.customSSHPort ?? serviceInfo?.sshPort ?? 22
    }

    public var nodeLocation: String {
        serviceInfo?.nodeLocation ?? "—"
    }

    public var osName: String {
        serviceInfo?.os ?? "—"
    }

    public var hostname: String {
        serviceInfo?.hostname ?? "—"
    }

    public var cpuUsageDescription: String {
        if let load = liveInfo?.load1Min {
            return String(format: "%.2f", load)
        }
        return "—"
    }

    public var memoryUsagePercentage: Double {
        liveInfo?.memoryUsedPercentage ?? 0.0
    }

    public var memoryUsageDescription: String {
        guard let used = liveInfo?.memUsedBytes, let total = liveInfo?.memoryTotalBytes else { return "—" }
        return "\(ByteCountFormatter.string(fromByteCount: used, countStyle: .binary)) / \(ByteCountFormatter.string(fromByteCount: total, countStyle: .binary))"
    }

    public var diskUsagePercentage: Double {
        liveInfo?.diskUsedPercentage ?? 0.0
    }

    public var diskUsageDescription: String {
        guard let used = liveInfo?.diskUsedBytes, let total = liveInfo?.diskTotalBytes else { return "—" }
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
