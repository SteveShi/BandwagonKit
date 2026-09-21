import Foundation

/// KiwiVM `getLiveServiceInfo` 接口响应，包含实时资源用量
public struct BWGLiveServiceInfo: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let vmType: String?
    public let loadAverage: String?
    public let memAvailableBytes: Int64?
    public let memUsedBytes: Int64?
    public let swapTotalBytes: Int64?
    public let swapAvailableBytes: Int64?
    public let swapUsedBytes: Int64?
    public let diskTotalBytes: Int64?
    public let diskUsedBytes: Int64?
    public let diskAvailableBytes: Int64?
    public let veStatus: String?

    enum CodingKeys: String, CodingKey {
        case error
        case message
        case vmType = "vm_type"
        case loadAverage = "load_average"
        case memAvailableBytes = "mem_available_bytes"
        case memUsedBytes = "mem_used_bytes"
        case swapTotalBytes = "swap_total_bytes"
        case swapAvailableBytes = "swap_available_bytes"
        case swapUsedBytes = "swap_used_bytes"
        case diskTotalBytes = "disk_total_bytes"
        case diskUsedBytes = "disk_used_bytes"
        case diskAvailableBytes = "disk_available_bytes"
        case veStatus = "ve_status"
    }

    public var isSuccess: Bool { error == 0 }

    public var isRunning: Bool {
        veStatus?.lowercased() == "running"
    }

    public var memoryTotalBytes: Int64? {
        guard let used = memUsedBytes, let avail = memAvailableBytes else { return nil }
        return used + avail
    }

    public var memoryUsedPercentage: Double {
        guard let used = memUsedBytes, let total = memoryTotalBytes, total > 0 else { return 0.0 }
        return min(max(Double(used) / Double(total), 0.0), 1.0)
    }

    public var diskUsedPercentage: Double {
        guard let total = diskTotalBytes, total > 0,
              let used = diskUsedBytes else { return 0.0 }
        return min(max(Double(used) / Double(total), 0.0), 1.0)
    }

    public var load1Min: Double? {
        guard let loadStr = loadAverage?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) else {
            return nil
        }
        return Double(loadStr)
    }

    public init(
        error: Int = 0,
        message: String? = nil,
        vmType: String? = nil,
        loadAverage: String? = nil,
        memAvailableBytes: Int64? = nil,
        memUsedBytes: Int64? = nil,
        swapTotalBytes: Int64? = nil,
        swapAvailableBytes: Int64? = nil,
        swapUsedBytes: Int64? = nil,
        diskTotalBytes: Int64? = nil,
        diskUsedBytes: Int64? = nil,
        diskAvailableBytes: Int64? = nil,
        veStatus: String? = nil
    ) {
        self.error = error
        self.message = message
        self.vmType = vmType
        self.loadAverage = loadAverage
        self.memAvailableBytes = memAvailableBytes
        self.memUsedBytes = memUsedBytes
        self.swapTotalBytes = swapTotalBytes
        self.swapAvailableBytes = swapAvailableBytes
        self.swapUsedBytes = swapUsedBytes
        self.diskTotalBytes = diskTotalBytes
        self.diskUsedBytes = diskUsedBytes
        self.diskAvailableBytes = diskAvailableBytes
        self.veStatus = veStatus
    }
}
