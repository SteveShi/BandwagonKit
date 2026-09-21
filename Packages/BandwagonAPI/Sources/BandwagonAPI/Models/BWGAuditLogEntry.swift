import Foundation

public struct BWGAuditLogItem: Codable, Sendable, Identifiable, Equatable {
    public var id: String { "\(timestamp)_\(type ?? "")_\(ip ?? "")" }
    public let timestamp: Int64
    public let type: String?
    public let ip: String?
    public let details: String?

    public var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    public init(timestamp: Int64, type: String? = nil, ip: String? = nil, details: String? = nil) {
        self.timestamp = timestamp
        self.type = type
        self.ip = ip
        self.details = details
    }
}

public struct BWGAuditLogResponse: Codable, Sendable {
    public let error: Int
    public let message: String?
    public let log: [BWGAuditLogItem]?

    public var isSuccess: Bool { error == 0 }

    public init(error: Int = 0, message: String? = nil, log: [BWGAuditLogItem]? = nil) {
        self.error = error
        self.message = message
        self.log = log
    }
}
