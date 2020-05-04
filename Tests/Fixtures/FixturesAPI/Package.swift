// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "FixturesAPI",
    products: [
        .library(name: "FixturesAPI", targets: ["FixturesAPI"]),
        .library(name: "FixturesAPITest", targets: ["FixturesAPITest"])
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/bow.git", .exact("0.8.0"))
    ],

    targets: [
        .target(name: "FixturesAPI",     dependencies: ["Bow", "BowEffects"], path: "Sources"),
        .target(name: "FixturesAPITest", dependencies: ["Bow", "BowEffects", "FixturesAPI"], path: "XCTest")
    ]
)
