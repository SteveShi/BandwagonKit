// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BandwagonAPI",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BandwagonAPI",
            targets: ["BandwagonAPI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BandwagonAPI",
            dependencies: [],
            path: "Sources/BandwagonAPI",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "BandwagonAPITests",
            dependencies: ["BandwagonAPI"],
            path: "Tests/BandwagonAPITests"
        )
    ]
)
