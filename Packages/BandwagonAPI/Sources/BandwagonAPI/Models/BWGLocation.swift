import Foundation

/// KiwiVM `migrate/getLocations` 响应
public struct BWGMigrationLocationsResponse: Codable, Sendable, Equatable {
    public let error: Int
    public let message: String?
    public let currentLocation: String?
    public let locations: [String]?
    public let descriptions: [String: String]?

    public var isSuccess: Bool { error == 0 }

    public var locationItems: [BWGLocationItem] {
        guard let locs = locations else { return [] }
        return locs.map { locId in
            BWGLocationItem(
                id: locId,
                name: descriptions?[locId] ?? locId,
                isCurrent: locId == currentLocation
            )
        }
    }

    public init(
        error: Int = 0,
        message: String? = nil,
        currentLocation: String? = nil,
        locations: [String]? = nil,
        descriptions: [String: String]? = nil
    ) {
        self.error = error
        self.message = message
        self.currentLocation = currentLocation
        self.locations = locations
        self.descriptions = descriptions
    }
}

public struct BWGLocationItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let isCurrent: Bool

    public init(id: String, name: String, isCurrent: Bool) {
        self.id = id
        self.name = name
        self.isCurrent = isCurrent
    }
}
