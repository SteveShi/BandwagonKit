import Foundation

/// KiwiVM `getRateLimitStatus` 响应
public struct BWGRateLimitStatus: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let remainingPoints15Min: Int?
    public let remainingPoints24H: Int?
    public let reset15Min: Int64?
    public let reset24H: Int64?

    enum CodingKeys: String, CodingKey {
        case error
        case message
        case remainingPoints15Min = "remaining_points_15min"
        case remainingPoints24H = "remaining_points_24h"
        case reset15Min = "reset_15min"
        case reset24H = "reset_24h"
    }

    public var isSuccess: Bool { error == 0 }

    public var reset15MinDate: Date? {
        guard let ts = reset15Min, ts > 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(ts))
    }

    public var reset24HDate: Date? {
        guard let ts = reset24H, ts > 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(ts))
    }

    public init(
        error: Int = 0,
        message: String? = nil,
        remainingPoints15Min: Int? = nil,
        remainingPoints24H: Int? = nil,
        reset15Min: Int64? = nil,
        reset24H: Int64? = nil
    ) {
        self.error = error
        self.message = message
        self.remainingPoints15Min = remainingPoints15Min
        self.remainingPoints24H = remainingPoints24H
        self.reset15Min = reset15Min
        self.reset24H = reset24H
    }
}
