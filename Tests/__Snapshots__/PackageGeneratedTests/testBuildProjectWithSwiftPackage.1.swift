// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "PetStore",
    products: [
        .library(name: "PetStore", targets: ["PetStore"]),
        .library(name: "PetStoreTest", targets: ["PetStoreTest"])
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/bow.git", .exact("0.6.0"))
    ],

    targets: [
        .target(name: "PetStore",     dependencies: ["Bow", "BowEffects"], path: "Sources"),
        .target(name: "PetStoreTest", dependencies: ["Bow", "BowEffects", "PetStore"], path: "XCTest")
    ]
)
