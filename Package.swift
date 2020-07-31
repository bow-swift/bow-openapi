// swift-tools-version:5.2
import PackageDescription

// MARK: - Dependencies
extension Target.Dependency {
    static var bow: Target.Dependency {
        .product(name: "Bow", package: "Bow")
    }
    
    static var bowEffects: Target.Dependency {
        .product(name: "BowEffects", package: "Bow")
    }
    
    static var bowOptics: Target.Dependency {
        .product(name: "BowOptics", package: "Bow")
    }
    
    static var swiftLine: Target.Dependency {
        .product(name: "Swiftline", package: "Swiftline")
    }
    
    static var swiftCheck: Target.Dependency {
        .product(name: "SwiftCheck", package: "SwiftCheck")
    }
    
    static var snapshotTesting: Target.Dependency {
        .product(name: "SnapshotTesting", package: "SnapshotTesting")
    }
    
    static var argumentParser: Target.Dependency {
        .product(name: "ArgumentParser", package: "swift-argument-parser")
    }
    
    static var fixturesAPI: Target.Dependency {
        .product(name: "FixturesAPI", package: "FixturesAPI")
    }
    
    static var fixturesAPITest: Target.Dependency {
        .product(name: "FixturesAPITest", package: "FixturesAPI")
    }
}

extension Target {
    var asDependency: Target.Dependency {
        .target(name: name)
    }
}

// MARK: - Libraries
extension Target {
    static var libraries: [Target] {
        [
            .openApiGenerator,
            .cli
        ]
    }
    
    static var openApiGenerator: Target {
        .target(name: "OpenApiGenerator",
                dependencies: [.bow,
                               .bowEffects,
                               .bowOptics,
                               .swiftLine],
                path: "OpenApiGenerator")
    }
    
    static var cli: Target {
        .target(name: "CLI",
                dependencies: [openApiGenerator.asDependency,
                               .argumentParser],
                path: "BowOpenAPI")
    }
}

// MARK: - Tests
extension Target {
    static var tests: [Target] {
        [
            .generatorTests
        ]
    }
    
    static var generatorTests: Target {
        .testTarget(name: "OpenApiGeneratorTests",
                    dependencies: [Target.openApiGenerator.asDependency,
                                   .bow,
                                   .bowEffects,
                                   .bowOptics,
                                   .snapshotTesting,
                                   .swiftCheck,
                                   .fixturesAPI,
                                   .fixturesAPITest],
                    path: "Tests",
                    exclude: ["__Snapshots__",
                              "Fixtures",
                              "Support Files"])
    }
}


// MARK: - Package
let package = Package(
    name: "Bow OpenAPI",
    
    platforms: [
        .macOS(.v10_14)
    ],
    
    products: [
        .executable(name: "bow-openapi", targets: [Target.cli.name])
    ],

    dependencies: [
        .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", .exact("0.8.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.2.1")),
        .package(url: "https://github.com/bow-swift/Swiftline.git", .exact("0.5.5")),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .exact("1.7.2")),
        .package(url: "https://github.com/bow-swift/SwiftCheck.git", .exact("0.12.1")),
        .package(path: "./Tests/Fixtures/FixturesAPI"),
    ],

    targets: [
        Target.libraries,
        Target.tests,
    ].flatMap { $0 }
)
