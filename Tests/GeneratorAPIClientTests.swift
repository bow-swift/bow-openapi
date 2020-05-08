//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects
@testable import OpenApiGenerator


class GeneratorAPIClientTests: XCTestCase {
    private let moduleName = "TestModule"
    private let fileSystem = MacFileSystem()
    private let output = URL.temp(subfolder: String(#file).filename.removeExtension)
    private let templates = URL.templates
    
    private func env(fileSystem: FileSystem) -> Environment {
        .init(logPath: "", fileSystem: fileSystem, generator: ClientGeneratorMock(shouldFail: false))
    }
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.createDirectoryIO(at: output, withIntermediateDirectories: true).unsafeRunSync()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItemIO(at: output).unsafeRunSync()
        super.tearDown()
    }
    
    
    func testCreateSwiftPackage() {
        let module = OpenAPIModule(name: output.path.filename,
                                   url: output.deletingLastPathComponent(),
                                   schema: URL(fileURLWithPath: ""),
                                   templates: templates)
        
        try? APIClient.createSwiftPackage(module: module)
                      .provide(env(fileSystem: fileSystem))
                      .unsafeRunSync()
        
        XCTAssertNotNil(output.find(item: "Package.swift"))
    }
    
    func testCreateStructure() {
        let module = OpenAPIModule(name: moduleName,
                                   url: output,
                                   schema: URL(fileURLWithPath: ""),
                                   templates: templates,
                                   sources: URL(fileURLWithPath: "\(output.path)/sources-testing"),
                                   tests: URL(fileURLWithPath: "\(output.path)/tests-testing"))
        
        try? APIClient.createStructure(module: module)
                      .provide(env(fileSystem: fileSystem))
                      .unsafeRunSync()
        
        XCTAssertNotNil(output.find(item: module.sources.path.filename))
        XCTAssertNotNil(output.find(item: module.tests.path.filename))
    }
    
    func testBow_CreateDefaultStructure() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystem, generator: clientGeneratorMock)
        let module = OpenAPIModule(name: moduleName,
                                   url: output,
                                   schema: URL.schemas.file(.model),
                                   templates: templates)
        
        _ = try? APIClient.bow(module: module)
                          .provide(environmentMock)
                          .unsafeRunSync()
        
        XCTAssertNotNil(output.find(item: "Sources"))
        XCTAssertNotNil(output.find(item: "XCTest"))
    }
    
    func testBow_GeneratorIsInvoked() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystem, generator: clientGeneratorMock)
        let module = OpenAPIModule(name: moduleName,
                                   url: output,
                                   schema: URL.schemas.file(.model),
                                   templates: templates)
        
        let either = APIClient.bow(module: module)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(clientGeneratorMock.generateInvoked)
        XCTAssertTrue(either.isRight)
    }
    
    func testBow_GeneratorFails_ReturnError() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: true)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystem, generator: clientGeneratorMock)
        let module = OpenAPIModule(name: moduleName,
                                   url: output,
                                   schema: URL.schemas.file(.model),
                                   templates: templates)
        
        let either = APIClient.bow(module: module)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(clientGeneratorMock.generateInvoked)
        XCTAssertTrue(either.isLeft)
    }
    
    func testBow_GeneratorAndFileSystemSuccess_ReturnSuccess() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: MacFileSystem(), generator: clientGeneratorMock)
        let module = OpenAPIModule(name: moduleName,
                                   url: output,
                                   schema: URL.schemas.file(.model),
                                   templates: templates)
        
        let either = APIClient.bow(module: module)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(either.isRight)
    }
    
    func testBow_FileSystemFails_ReturnError() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: FileSystemMock(shouldFail: true), generator: clientGeneratorMock)
        let module = OpenAPIModule(name: moduleName,
                                   url: output,
                                   schema: URL.schemas.file(.model),
                                   templates: templates)
        
        let either = APIClient.bow(module: module)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(either.isLeft)
    }
}
