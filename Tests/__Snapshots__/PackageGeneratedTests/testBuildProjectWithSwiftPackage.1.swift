// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Bow API Client",
    products: [
        .library(name: "BowAPIClient", targets: ["BowAPIClient"]),
        .library(name: "BowAPIClientTest", targets: ["BowAPIClientTest"])
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/bow.git", .exact("0.6.0"))
    ],

    targets: [
        .target(name: "BowAPIClient",     dependencies: ["Bow", "BowEffects"], path: "Sources"),
        .target(name: "BowAPIClientTest", dependencies: ["Bow", "BowEffects"], path: "XCTest")
    ]
)
