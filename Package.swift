// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "BowOpenAPI",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(name: "bow-openapi", targets: ["BowOpenAPI"])
    ],

    dependencies: [
        .package(url: "https://github.com/bow-swift/bow.git", .exact("0.6.0")),
        .package(url: "https://github.com/bow-swift/Swiftline.git", .exact("0.5.3"))
    ],

    targets: [
        .target(name: "OpenApiGenerator",
                dependencies: ["Bow", "BowEffects", "BowOptics", "Swiftline"],
                path: "OpenApiGenerator"),

        .target(name: "BowOpenAPI",
                dependencies: ["OpenApiGenerator"],
                path: "BowOpenApi")
    ]
)
