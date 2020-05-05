// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PetStore",
    products: [
        .library(name: "PetStore", targets: ["PetStore"]),
        .library(name: "PetStoreTest", targets: ["PetStoreTest"])
    ],

    dependencies: [
        .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", .exact("0.8.0"))
    ],

    targets: [
        .target(name: "PetStore",
                dependencies: [.product(name: "Bow", package: "Bow"),
                               .product(name: "BowEffects", package: "Bow")],
                path: "Sources"),
        
        .target(name: "PetStoreTest",
                dependencies: [.target(name: "PetStore"),
                               .product(name: "Bow", package: "Bow"),
                               .product(name: "BowEffects", package: "Bow")],
                path: "XCTest")
    ]
)
