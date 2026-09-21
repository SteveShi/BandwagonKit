import Foundation

/// KiwiVM `getDiskIO` 响应
public struct BWGDiskIO: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let readBytes: Int64?
    public let writeBytes: Int64?

    enum CodingKeys: String, CodingKey {
        case error
        case message
        case readBytes = "read_bytes"
        case writeBytes = "write_bytes"
    }

    public var isSuccess: Bool { error == 0 }

    public init(error: Int = 0, message: String? = nil, readBytes: Int64? = nil, writeBytes: Int64? = nil) {
        self.error = error
        self.message = message
        self.readBytes = readBytes
        self.writeBytes = writeBytes
    }
}
