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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.error = (try? container.decode(Int.self, forKey: .error)) ?? 0
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        self.vmType = try? container.decodeIfPresent(String.self, forKey: .vmType)
        self.hostname = try? container.decodeIfPresent(String.self, forKey: .hostname)
        self.nodeIp = try? container.decodeIfPresent(String.self, forKey: .nodeIp)
        self.nodeAlias = try? container.decodeIfPresent(String.self, forKey: .nodeAlias)
        self.nodeLocation = try? container.decodeIfPresent(String.self, forKey: .nodeLocation)
        self.plan = try? container.decodeIfPresent(String.self, forKey: .plan)
        self.os = try? container.decodeIfPresent(String.self, forKey: .os)
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.ipAddresses = try? container.decodeIfPresent([String].self, forKey: .ipAddresses)
        self.sshPort = try? container.decodeIfPresent(Int.self, forKey: .sshPort)

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

        func decodeBool(_ key: CodingKeys) -> Bool? {
            if let val = try? container.decodeIfPresent(Bool.self, forKey: key) {
                return val
            }
            if let val = try? container.decodeIfPresent(Int.self, forKey: key) {
                return val == 1
            }
            if let str = try? container.decodeIfPresent(String.self, forKey: key) {
                let trimmed = str.trimmingCharacters(in: .whitespaces).lowercased()
                return trimmed == "1" || trimmed == "true"
            }
            return nil
        }

        self.planMonthlyData = decodeInt64(.planMonthlyData)
        self.monthlyDataMultiplier = decodeDouble(.monthlyDataMultiplier)
        self.planDisk = decodeInt64(.planDisk)
        self.planRam = decodeInt64(.planRam)
        self.planSwap = decodeInt64(.planSwap)
        self.dataCounter = decodeInt64(.dataCounter)
        self.dataNextReset = decodeInt64(.dataNextReset)

        self.locationIpv6Ready = decodeBool(.locationIpv6Ready)
        self.rdnsApiAvailable = decodeBool(.rdnsApiAvailable)
        self.suspended = decodeBool(.suspended)

        // ptr: 兼容 PHP 空关联数组返回 `[]` 的情况，也支持 `{"ip": "domain"}`
        if let dict = try? container.decodeIfPresent([String: String].self, forKey: .ptr) {
            self.ptr = dict
        } else {
            self.ptr = [:]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(error, forKey: .error)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(vmType, forKey: .vmType)
        try container.encodeIfPresent(hostname, forKey: .hostname)
        try container.encodeIfPresent(nodeIp, forKey: .nodeIp)
        try container.encodeIfPresent(nodeAlias, forKey: .nodeAlias)
        try container.encodeIfPresent(nodeLocation, forKey: .nodeLocation)
        try container.encodeIfPresent(locationIpv6Ready, forKey: .locationIpv6Ready)
        try container.encodeIfPresent(plan, forKey: .plan)
        try container.encodeIfPresent(planMonthlyData, forKey: .planMonthlyData)
        try container.encodeIfPresent(monthlyDataMultiplier, forKey: .monthlyDataMultiplier)
        try container.encodeIfPresent(planDisk, forKey: .planDisk)
        try container.encodeIfPresent(planRam, forKey: .planRam)
        try container.encodeIfPresent(planSwap, forKey: .planSwap)
        try container.encodeIfPresent(os, forKey: .os)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(dataCounter, forKey: .dataCounter)
        try container.encodeIfPresent(dataNextReset, forKey: .dataNextReset)
        try container.encodeIfPresent(ipAddresses, forKey: .ipAddresses)
        try container.encodeIfPresent(rdnsApiAvailable, forKey: .rdnsApiAvailable)
        try container.encodeIfPresent(ptr, forKey: .ptr)
        try container.encodeIfPresent(suspended, forKey: .suspended)
        try container.encodeIfPresent(sshPort, forKey: .sshPort)
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
