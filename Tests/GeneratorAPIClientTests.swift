//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects

@testable import OpenApiGenerator


class GeneratorAPIClientTests: XCTestCase {
    
    private let moduleName = "TestModule"
    private let fileSystem = MacFileSystem()
    private let output = URL.temp(subfolder: String(#file).filename.removeExtension)
    private let template = URL.templates
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.createDirectoryIO(at: output, withIntermediateDirectories: true).unsafeRunSync()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItemIO(at: output).unsafeRunSync()
        super.tearDown()
    }
    
    
    func testCreateSwiftPackage() {
        try? APIClient.createSwiftPackage(moduleName: moduleName, outputPath: output.path, templatePath: template.path)
                      .provide(fileSystem)
                      .unsafeRunSync()
        
        XCTAssertNotNil(output.find(item: "Package.swift"))
    }
    
    func testCreateStructure() {
        let outputPath = OutputPath(sources: "\(output.path)/sources-testing", tests: "\(output.path)/tests-testing")
        
        try? APIClient.createStructure(outputPath: outputPath)
                      .provide(fileSystem)
                      .unsafeRunSync()
        
        XCTAssertNotNil(output.find(item: outputPath.sources.filename))
        XCTAssertNotNil(output.find(item: outputPath.tests.filename))
    }
    
    func testBow_CreateDefaultStructure() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystem, generator: clientGeneratorMock)
        
        _ = try? APIClient.bow(moduleName: moduleName, scheme: URL.schemas.file(.model).path, output: output.path, templatePath: template.path)
                          .provide(environmentMock)
                          .unsafeRunSync()
        
        XCTAssertNotNil(output.find(item: "Sources"))
        XCTAssertNotNil(output.find(item: "XCTest"))
    }
    
    func testBow_GeneratorIsInvoked() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystem, generator: clientGeneratorMock)
        
        let either = APIClient.bow(moduleName: moduleName, scheme: URL.schemas.file(.model).path, output: output.path, templatePath: template.path)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(clientGeneratorMock.generateInvoked)
        XCTAssertTrue(either.isRight)
    }
    
    func testBow_GeneratorFails_ReturnError() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: true)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystem, generator: clientGeneratorMock)
        
        let either = APIClient.bow(moduleName: moduleName, scheme: URL.schemas.file(.model).path, output: output.path, templatePath: template.path)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(clientGeneratorMock.generateInvoked)
        XCTAssertTrue(either.isLeft)
    }
    
    func testBow_GeneratorAndFileSystemSuccess_ReturnSuccess() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let fileSystemMock = FileSystemMock(shouldFail: false)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystemMock, generator: clientGeneratorMock)
        
        let either = APIClient.bow(moduleName: moduleName, scheme: URL.schemas.file(.model).path, output: output.path, templatePath: template.path)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(either.isRight)
    }
    
    func testBow_FileSystemFails_ReturnError() {
        let clientGeneratorMock = ClientGeneratorMock(shouldFail: false)
        let fileSystemMock = FileSystemMock(shouldFail: true)
        let environmentMock = Environment(logPath: "\(output.path)/log.1.txt", fileSystem: fileSystemMock, generator: clientGeneratorMock)
        
        let either = APIClient.bow(moduleName: moduleName, scheme: URL.schemas.file(.model).path, output: output.path, templatePath: template.path)
                              .provide(environmentMock)
                              .unsafeRunSyncEither()
        
        XCTAssertTrue(either.isLeft)
    }
}
