import Foundation

/// KiwiVM API 基础响应，所有接口均包含 error 字段
public struct BWGAPIResponse: Codable, Sendable {
    public let error: Int
    public let message: String?

    public var isSuccess: Bool {
        error == 0
    }

    public init(error: Int, message: String? = nil) {
        self.error = error
        self.message = message
    }
}
