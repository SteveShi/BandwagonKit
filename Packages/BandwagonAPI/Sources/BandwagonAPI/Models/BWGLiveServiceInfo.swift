import Foundation

/// KiwiVM `getLiveServiceInfo` 接口响应，包含实时资源用量与运行状态
public struct BWGLiveServiceInfo: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let vmType: String?
    public let veStatus: String?
    public let loadAverage: String?
    public let isCpuThrottled: Int?
    public let liveHostname: String?
    public let veMac1: String?
    public let sshPort: Int?

    // 官方 KiwiVM API 实际返回字段
    public let memAvailableKB: Int64?
    public let planRam: Int64?
    public let swapTotalKB: Int64?
    public let swapAvailableKB: Int64?
    public let planSwap: Int64?
    public let veUsedDiskSpaceBytes: Int64?
    public let veDiskQuotaGB: Double?
    public let planDisk: Int64?

    // 兼容历史/测试/老格式字段
    public let memAvailableBytesRaw: Int64?
    public let memUsedBytesRaw: Int64?
    public let swapTotalBytesRaw: Int64?
    public let swapAvailableBytesRaw: Int64?
    public let swapUsedBytesRaw: Int64?
    public let diskTotalBytesRaw: Int64?
    public let diskUsedBytesRaw: Int64?
    public let diskAvailableBytesRaw: Int64?

    enum CodingKeys: String, CodingKey {
        case error
        case message
        case vmType = "vm_type"
        case veStatus = "ve_status"
        case loadAverage = "load_average"
        case isCpuThrottled = "is_cpu_throttled"
        case liveHostname = "live_hostname"
        case veMac1 = "ve_mac1"
        case sshPort = "ssh_port"

        case memAvailableKB = "mem_available_kb"
        case planRam = "plan_ram"
        case swapTotalKB = "swap_total_kb"
        case swapAvailableKB = "swap_available_kb"
        case planSwap = "plan_swap"
        case veUsedDiskSpaceBytes = "ve_used_disk_space_b"
        case veDiskQuotaGB = "ve_disk_quota_gb"
        case planDisk = "plan_disk"

        case memAvailableBytesRaw = "mem_available_bytes"
        case memUsedBytesRaw = "mem_used_bytes"
        case swapTotalBytesRaw = "swap_total_bytes"
        case swapAvailableBytesRaw = "swap_available_bytes"
        case swapUsedBytesRaw = "swap_used_bytes"
        case diskTotalBytesRaw = "disk_total_bytes"
        case diskUsedBytesRaw = "disk_used_bytes"
        case diskAvailableBytesRaw = "disk_available_bytes"
    }

    public var isSuccess: Bool { error == 0 }

    public var isRunning: Bool {
        veStatus?.trimmingCharacters(in: .whitespaces).lowercased() == "running"
    }

    // MARK: - Memory

    public var memAvailableBytes: Int64? {
        if let kb = memAvailableKB {
            return kb * 1024
        }
        return memAvailableBytesRaw
    }

    public var memoryTotalBytes: Int64? {
        if let plan = planRam, plan > 0 {
            return plan
        }
        if let used = memUsedBytesRaw, let avail = memAvailableBytesRaw {
            return used + avail
        }
        return nil
    }

    public var memUsedBytes: Int64? {
        if let used = memUsedBytesRaw {
            return used
        }
        guard let total = memoryTotalBytes, let avail = memAvailableBytes else {
            return nil
        }
        return max(0, total - avail)
    }

    public var memoryUsedPercentage: Double {
        guard let used = memUsedBytes, let total = memoryTotalBytes, total > 0 else { return 0.0 }
        return min(max(Double(used) / Double(total), 0.0), 1.0)
    }

    // MARK: - Disk

    public var diskUsedBytes: Int64? {
        veUsedDiskSpaceBytes ?? diskUsedBytesRaw
    }

    public var diskTotalBytes: Int64? {
        if let plan = planDisk, plan > 0 {
            return plan
        }
        if let quotaGB = veDiskQuotaGB, quotaGB > 0 {
            return Int64(quotaGB * 1024 * 1024 * 1024)
        }
        return diskTotalBytesRaw
    }

    public var diskAvailableBytes: Int64? {
        if let raw = diskAvailableBytesRaw {
            return raw
        }
        guard let total = diskTotalBytes, let used = diskUsedBytes else { return nil }
        return max(0, total - used)
    }

    public var diskUsedPercentage: Double {
        guard let total = diskTotalBytes, total > 0,
              let used = diskUsedBytes else { return 0.0 }
        return min(max(Double(used) / Double(total), 0.0), 1.0)
    }

    // MARK: - Swap

    public var swapTotalBytes: Int64? {
        if let plan = planSwap, plan > 0 {
            return plan
        }
        if let kb = swapTotalKB {
            return kb * 1024
        }
        return swapTotalBytesRaw
    }

    public var swapAvailableBytes: Int64? {
        if let kb = swapAvailableKB {
            return kb * 1024
        }
        return swapAvailableBytesRaw
    }

    public var swapUsedBytes: Int64? {
        if let raw = swapUsedBytesRaw {
            return raw
        }
        guard let total = swapTotalBytes, let avail = swapAvailableBytes else { return nil }
        return max(0, total - avail)
    }

    // MARK: - Load Average

    public var loadAverages: [Double] {
        guard let loadStr = loadAverage else { return [] }
        let tokens = loadStr.components(separatedBy: CharacterSet(charactersIn: ", \t\n\r"))
        var results: [Double] = []
        for token in tokens {
            let clean = token.trimmingCharacters(in: .whitespaces)
            guard !clean.isEmpty else { continue }
            // 在 Linux /proc/loadavg 中，若遇到 "1/150" 形式的进程计数字段，则后面为 PID，停止解析
            if clean.contains("/") {
                break
            }
            if let val = Double(clean) {
                results.append(val)
                if results.count == 3 {
                    break
                }
            }
        }
        return results
    }

    public var load1Min: Double? {
        loadAverages.first
    }

    public var load5Min: Double? {
        loadAverages.count > 1 ? loadAverages[1] : nil
    }

    public var load15Min: Double? {
        loadAverages.count > 2 ? loadAverages[2] : nil
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.error = (try? container.decode(Int.self, forKey: .error)) ?? 0
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        self.vmType = try? container.decodeIfPresent(String.self, forKey: .vmType)
        self.veStatus = try? container.decodeIfPresent(String.self, forKey: .veStatus)
        self.liveHostname = try? container.decodeIfPresent(String.self, forKey: .liveHostname)
        self.veMac1 = try? container.decodeIfPresent(String.self, forKey: .veMac1)
        self.sshPort = try? container.decodeIfPresent(Int.self, forKey: .sshPort)

        if let str = try? container.decodeIfPresent(String.self, forKey: .loadAverage) {
            self.loadAverage = str
        } else if let arr = try? container.decodeIfPresent([Double].self, forKey: .loadAverage) {
            self.loadAverage = arr.map { String($0) }.joined(separator: " ")
        } else if let num = try? container.decodeIfPresent(Double.self, forKey: .loadAverage) {
            self.loadAverage = String(num)
        } else if let num = try? container.decodeIfPresent(Int.self, forKey: .loadAverage) {
            self.loadAverage = String(num)
        } else {
            self.loadAverage = nil
        }

        if let val = try? container.decodeIfPresent(Int.self, forKey: .isCpuThrottled) {
            self.isCpuThrottled = val
        } else if let boolVal = try? container.decodeIfPresent(Bool.self, forKey: .isCpuThrottled) {
            self.isCpuThrottled = boolVal ? 1 : 0
        } else {
            self.isCpuThrottled = nil
        }

        func decodeInt64(_ key: CodingKeys) -> Int64? {
            if let val = try? container.decodeIfPresent(Int64.self, forKey: key) {
                return val
            }
            if let val = try? container.decodeIfPresent(Int.self, forKey: key) {
                return Int64(val)
            }
            if let val = try? container.decodeIfPresent(Double.self, forKey: key) {
                return Int64(val)
            }
            if let str = try? container.decodeIfPresent(String.self, forKey: key) {
                return Int64(str)
            }
            return nil
        }

        func decodeDouble(_ key: CodingKeys) -> Double? {
            if let val = try? container.decodeIfPresent(Double.self, forKey: key) {
                return val
            }
            if let val = try? container.decodeIfPresent(Int64.self, forKey: key) {
                return Double(val)
            }
            if let val = try? container.decodeIfPresent(Int.self, forKey: key) {
                return Double(val)
            }
            if let str = try? container.decodeIfPresent(String.self, forKey: key) {
                return Double(str)
            }
            return nil
        }

        self.memAvailableKB = decodeInt64(.memAvailableKB)
        self.planRam = decodeInt64(.planRam)
        self.swapTotalKB = decodeInt64(.swapTotalKB)
        self.swapAvailableKB = decodeInt64(.swapAvailableKB)
        self.planSwap = decodeInt64(.planSwap)
        self.veUsedDiskSpaceBytes = decodeInt64(.veUsedDiskSpaceBytes)
        self.veDiskQuotaGB = decodeDouble(.veDiskQuotaGB)
        self.planDisk = decodeInt64(.planDisk)

        self.memAvailableBytesRaw = decodeInt64(.memAvailableBytesRaw)
        self.memUsedBytesRaw = decodeInt64(.memUsedBytesRaw)
        self.swapTotalBytesRaw = decodeInt64(.swapTotalBytesRaw)
        self.swapAvailableBytesRaw = decodeInt64(.swapAvailableBytesRaw)
        self.swapUsedBytesRaw = decodeInt64(.swapUsedBytesRaw)
        self.diskTotalBytesRaw = decodeInt64(.diskTotalBytesRaw)
        self.diskUsedBytesRaw = decodeInt64(.diskUsedBytesRaw)
        self.diskAvailableBytesRaw = decodeInt64(.diskAvailableBytesRaw)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(error, forKey: .error)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(vmType, forKey: .vmType)
        try container.encodeIfPresent(veStatus, forKey: .veStatus)
        try container.encodeIfPresent(loadAverage, forKey: .loadAverage)
        try container.encodeIfPresent(isCpuThrottled, forKey: .isCpuThrottled)
        try container.encodeIfPresent(liveHostname, forKey: .liveHostname)
        try container.encodeIfPresent(veMac1, forKey: .veMac1)
        try container.encodeIfPresent(sshPort, forKey: .sshPort)

        try container.encodeIfPresent(memAvailableKB, forKey: .memAvailableKB)
        try container.encodeIfPresent(planRam, forKey: .planRam)
        try container.encodeIfPresent(swapTotalKB, forKey: .swapTotalKB)
        try container.encodeIfPresent(swapAvailableKB, forKey: .swapAvailableKB)
        try container.encodeIfPresent(planSwap, forKey: .planSwap)
        try container.encodeIfPresent(veUsedDiskSpaceBytes, forKey: .veUsedDiskSpaceBytes)
        try container.encodeIfPresent(veDiskQuotaGB, forKey: .veDiskQuotaGB)
        try container.encodeIfPresent(planDisk, forKey: .planDisk)

        try container.encodeIfPresent(memAvailableBytesRaw, forKey: .memAvailableBytesRaw)
        try container.encodeIfPresent(memUsedBytesRaw, forKey: .memUsedBytesRaw)
        try container.encodeIfPresent(swapTotalBytesRaw, forKey: .swapTotalBytesRaw)
        try container.encodeIfPresent(swapAvailableBytesRaw, forKey: .swapAvailableBytesRaw)
        try container.encodeIfPresent(swapUsedBytesRaw, forKey: .swapUsedBytesRaw)
        try container.encodeIfPresent(diskTotalBytesRaw, forKey: .diskTotalBytesRaw)
        try container.encodeIfPresent(diskUsedBytesRaw, forKey: .diskUsedBytesRaw)
        try container.encodeIfPresent(diskAvailableBytesRaw, forKey: .diskAvailableBytesRaw)
    }

    public init(
        error: Int = 0,
        message: String? = nil,
        vmType: String? = nil,
        veStatus: String? = nil,
        loadAverage: String? = nil,
        isCpuThrottled: Int? = nil,
        liveHostname: String? = nil,
        veMac1: String? = nil,
        sshPort: Int? = nil,
        memAvailableKB: Int64? = nil,
        planRam: Int64? = nil,
        swapTotalKB: Int64? = nil,
        swapAvailableKB: Int64? = nil,
        planSwap: Int64? = nil,
        veUsedDiskSpaceBytes: Int64? = nil,
        veDiskQuotaGB: Double? = nil,
        planDisk: Int64? = nil,
        memAvailableBytes: Int64? = nil,
        memUsedBytes: Int64? = nil,
        swapTotalBytes: Int64? = nil,
        swapAvailableBytes: Int64? = nil,
        swapUsedBytes: Int64? = nil,
        diskTotalBytes: Int64? = nil,
        diskUsedBytes: Int64? = nil,
        diskAvailableBytes: Int64? = nil
    ) {
        self.error = error
        self.message = message
        self.vmType = vmType
        self.veStatus = veStatus
        self.loadAverage = loadAverage
        self.isCpuThrottled = isCpuThrottled
        self.liveHostname = liveHostname
        self.veMac1 = veMac1
        self.sshPort = sshPort
        self.memAvailableKB = memAvailableKB
        self.planRam = planRam
        self.swapTotalKB = swapTotalKB
        self.swapAvailableKB = swapAvailableKB
        self.planSwap = planSwap
        self.veUsedDiskSpaceBytes = veUsedDiskSpaceBytes
        self.veDiskQuotaGB = veDiskQuotaGB
        self.planDisk = planDisk
        self.memAvailableBytesRaw = memAvailableBytes
        self.memUsedBytesRaw = memUsedBytes
        self.swapTotalBytesRaw = swapTotalBytes
        self.swapAvailableBytesRaw = swapAvailableBytes
        self.swapUsedBytesRaw = swapUsedBytes
        self.diskTotalBytesRaw = diskTotalBytes
        self.diskUsedBytesRaw = diskUsedBytes
        self.diskAvailableBytesRaw = diskAvailableBytes
    }
}
