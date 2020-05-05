// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "{{ moduleName }}",
    products: [
        .library(name: "{{ moduleName }}", targets: ["{{ moduleName }}"]),
        .library(name: "{{ moduleName }}Test", targets: ["{{ moduleName }}Test"])
    ],

    dependencies: [
        .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", .exact("0.8.0"))
    ],

    targets: [
        .target(name: "{{ moduleName }}",
                dependencies: [.product(name: "Bow", package: "Bow"),
                               .product(name: "BowEffects", package: "Bow")],
                path: "Sources"),
        
        .target(name: "{{ moduleName }}Test",
                dependencies: [.target(name: "{{ moduleName }}"),
                               .product(name: "Bow", package: "Bow"),
                               .product(name: "BowEffects", package: "Bow")],
                path: "XCTest")
    ]
)
