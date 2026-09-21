import Foundation

/// KiwiVM `getAvailableOS` 响应
public struct BWGAvailableOS: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let installed: String?
    public let templates: [String]?

    public var isSuccess: Bool { error == 0 }

    public init(error: Int = 0, message: String? = nil, installed: String? = nil, templates: [String]? = nil) {
        self.error = error
        self.message = message
        self.installed = installed
        self.templates = templates
    }
}
