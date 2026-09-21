import Foundation

/// KiwiVM `getServiceInfo` 接口响应
public struct BWGServiceInfo: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let vmType: String?
    public let hostname: String?
    public let nodeIp: String?
    public let nodeAlias: String?
    public let nodeLocation: String?
    public let locationIpv6Ready: Bool?
    public let plan: String?
    public let planMonthlyData: Int64?
    public let monthlyDataMultiplier: Double?
    public let planDisk: Int64?
    public let planRam: Int64?
    public let planSwap: Int64?
    public let os: String?
    public let email: String?
    public let dataCounter: Int64?
    public let dataNextReset: Int64?
    public let ipAddresses: [String]?
    public let rdnsApiAvailable: Bool?
    public let ptr: [String: String]?
    public let suspended: Bool?
    public let sshPort: Int?

    enum CodingKeys: String, CodingKey {
        case error
        case message
        case vmType = "vm_type"
        case hostname
        case nodeIp = "node_ip"
        case nodeAlias = "node_alias"
        case nodeLocation = "node_location"
        case locationIpv6Ready = "location_ipv6_ready"
        case plan
        case planMonthlyData = "plan_monthly_data"
        case monthlyDataMultiplier = "monthly_data_multiplier"
        case planDisk = "plan_disk"
        case planRam = "plan_ram"
        case planSwap = "plan_swap"
        case os
        case email
        case dataCounter = "data_counter"
        case dataNextReset = "data_next_reset"
        case ipAddresses = "ip_addresses"
        case rdnsApiAvailable = "rdns_api_available"
        case ptr
        case suspended
        case sshPort = "ssh_port"
    }

    public var isSuccess: Bool { error == 0 }

    public var primaryIP: String? {
        ipAddresses?.first
    }

    public var bandwidthUsedPercentage: Double {
        guard let total = planMonthlyData, total > 0,
              let used = dataCounter else { return 0.0 }
        return min(max(Double(used) / Double(total), 0.0), 1.0)
    }

    public var dataResetDate: Date? {
        guard let timestamp = dataNextReset, timestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    public init(
        error: Int = 0,
        message: String? = nil,
        vmType: String? = nil,
        hostname: String? = nil,
        nodeIp: String? = nil,
        nodeAlias: String? = nil,
        nodeLocation: String? = nil,
        locationIpv6Ready: Bool? = nil,
        plan: String? = nil,
        planMonthlyData: Int64? = nil,
        monthlyDataMultiplier: Double? = nil,
        planDisk: Int64? = nil,
        planRam: Int64? = nil,
        planSwap: Int64? = nil,
        os: String? = nil,
        email: String? = nil,
        dataCounter: Int64? = nil,
        dataNextReset: Int64? = nil,
        ipAddresses: [String]? = nil,
        rdnsApiAvailable: Bool? = nil,
        ptr: [String: String]? = nil,
        suspended: Bool? = nil,
        sshPort: Int? = nil
    ) {
        self.error = error
        self.message = message
        self.vmType = vmType
        self.hostname = hostname
        self.nodeIp = nodeIp
        self.nodeAlias = nodeAlias
        self.nodeLocation = nodeLocation
        self.locationIpv6Ready = locationIpv6Ready
        self.plan = plan
        self.planMonthlyData = planMonthlyData
        self.monthlyDataMultiplier = monthlyDataMultiplier
        self.planDisk = planDisk
        self.planRam = planRam
        self.planSwap = planSwap
        self.os = os
        self.email = email
        self.dataCounter = dataCounter
        self.dataNextReset = dataNextReset
        self.ipAddresses = ipAddresses
        self.rdnsApiAvailable = rdnsApiAvailable
        self.ptr = ptr
        self.suspended = suspended
        self.sshPort = sshPort
    }
}
