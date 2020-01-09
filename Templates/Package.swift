// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "{{ moduleName }}",
    products: [
        .library(name: "{{ moduleName }}", targets: ["{{ moduleName }}"]),
        .library(name: "{{ moduleName }}Test", targets: ["{{ moduleName }}Test"])
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/bow.git", .exact("0.7.0"))
    ],

    targets: [
        .target(name: "{{ moduleName }}",     dependencies: ["Bow", "BowEffects"], path: "Sources"),
        .target(name: "{{ moduleName }}Test", dependencies: ["Bow", "BowEffects", "{{ moduleName }}"], path: "XCTest")
    ]
)
