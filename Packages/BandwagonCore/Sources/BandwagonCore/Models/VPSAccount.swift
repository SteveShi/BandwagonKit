import Foundation

/// 存储 VPS 主机配置元数据
public struct VPSAccount: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var veid: String
    public var colorHex: String?
    public var customSSHPort: Int?
    public var defaultTerminal: String?
    public var createdDate: Date

    public init(
        id: UUID = UUID(),
        name: String,
        veid: String,
        colorHex: String? = nil,
        customSSHPort: Int? = nil,
        defaultTerminal: String? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.veid = veid
        self.colorHex = colorHex
        self.customSSHPort = customSSHPort
        self.defaultTerminal = defaultTerminal
        self.createdDate = createdDate
    }
}
