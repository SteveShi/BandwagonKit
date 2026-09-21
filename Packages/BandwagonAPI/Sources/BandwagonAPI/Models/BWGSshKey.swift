import Foundation

/// KiwiVM SSH 公钥
public struct BWGSshKeyItem: Codable, Sendable, Identifiable, Equatable {
    public var id: String { key }
    public let name: String?
    public let key: String

    public init(name: String? = nil, key: String) {
        self.name = name
        self.key = key
    }
}

public struct BWGSshKeysResponse: Codable, Sendable {
    public let error: Int
    public let message: String?
    public let keys: [BWGSshKeyItem]?

    public var isSuccess: Bool { error == 0 }

    public init(error: Int = 0, message: String? = nil, keys: [BWGSshKeyItem]? = nil) {
        self.error = error
        self.message = message
        self.keys = keys
    }
}
