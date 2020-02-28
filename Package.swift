// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Bow OpenAPI",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(name: "bow-openapi", targets: ["CLI"])
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/bow.git", .exact("0.6.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1"),
        .package(url: "https://github.com/bow-swift/Swiftline.git", .exact("0.5.3"))
    ],

    targets: [
        .target(name: "OpenApiGenerator",
                dependencies: ["Bow", "BowEffects", "BowOptics", "Swiftline"],
                path: "OpenApiGenerator"),

        .target(name: "CLI",
                dependencies: ["OpenApiGenerator", "ArgumentParser"],
                path: "BowOpenAPI")
    ]
)
