// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BandwagonCore",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BandwagonCore",
            targets: ["BandwagonCore"]
        )
    ],
    dependencies: [
        .package(path: "../BandwagonAPI")
    ],
    targets: [
        .target(
            name: "BandwagonCore",
            dependencies: [
                "BandwagonAPI"
            ],
            path: "Sources/BandwagonCore",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "BandwagonCoreTests",
            dependencies: [
                "BandwagonCore",
                "BandwagonAPI"
            ],
            path: "Tests/BandwagonCoreTests"
        )
    ]
)
