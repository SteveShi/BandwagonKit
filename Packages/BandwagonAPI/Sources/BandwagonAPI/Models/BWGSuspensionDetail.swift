import Foundation

/// KiwiVM `getSuspensionDetail` 响应
public struct BWGSuspensionDetail: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let isSuspended: Bool?
    public let reason: String?

    enum CodingKeys: String, CodingKey {
        case error
        case message
        case isSuspended = "is_suspended"
        case reason
    }

    public var isSuccess: Bool { error == 0 }

    public init(error: Int = 0, message: String? = nil, isSuspended: Bool? = nil, reason: String? = nil) {
        self.error = error
        self.message = message
        self.isSuspended = isSuspended
        self.reason = reason
    }
}
