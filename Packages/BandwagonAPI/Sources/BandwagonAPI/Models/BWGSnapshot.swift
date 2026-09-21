import Foundation

/// 快照信息
public struct BWGSnapshotItem: Codable, Sendable, Identifiable, Equatable {
    public var id: String { fileName }
    public let fileName: String
    public let size: Int64?
    public let md5: String?
    public let os: String?
    public let purgesIn: Int?
    public let isSticky: Bool?
    public let description: String?

    public init(
        fileName: String,
        size: Int64? = nil,
        md5: String? = nil,
        os: String? = nil,
        purgesIn: Int? = nil,
        isSticky: Bool? = nil,
        description: String? = nil
    ) {
        self.fileName = fileName
        self.size = size
        self.md5 = md5
        self.os = os
        self.purgesIn = purgesIn
        self.isSticky = isSticky
        self.description = description
    }
}

/// KiwiVM `snapshot/list` 响应
public struct BWGSnapshotListResponse: Codable, Sendable {
    public let error: Int
    public let message: String?
    public let snapshots: [BWGSnapshotItem]?

    public var isSuccess: Bool { error == 0 }

    public init(error: Int = 0, message: String? = nil, snapshots: [BWGSnapshotItem]? = nil) {
        self.error = error
        self.message = message
        self.snapshots = snapshots
    }
}
