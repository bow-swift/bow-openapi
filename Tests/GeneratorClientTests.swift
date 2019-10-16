//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects

@testable import OpenApiGenerator


class GeneratorClientTests: XCTestCase {
    
    private let sut = SwaggerClientGenerator()
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
    
    
    func testRemoveHeaderSection_ReturnFileUpdated() {
        let fileURL = output.appendingPathComponent("TestRemoveHeaderSection_Valid.swift")
        let contentFile = """
                          /* \(Constants.headerKey)
                                ----
                                ----
                          */
                          """

        try? contentFile.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(fileSystem).unsafeRunSyncEither()
        let newContentFile = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(newContentFile, "")
    }
    
    func testRemoveHeaderSection_WithExtraContent_ReturnFileUpdated() {
        let fileURL = output.appendingPathComponent("TestRemoveHeaderSection_WithExtraContent.swift")
        let extraContent = "let hola    "
        let extraContentFile = """
                               \(extraContent)/* \(Constants.headerKey)
                                        ----
                                        ----
                                */
                               """

        try? extraContentFile.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(fileSystem).unsafeRunSyncEither()
        let newContentFile = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(newContentFile, extraContent)
    }
    
    func testRemoveHeaderSection_WithoutContent_ReturnSameFile() {
        let fileURL = output.appendingPathComponent("TestRemoveHeaderSection_WithoutContent.swift")
        let noContentFile = "/* \(Constants.headerKey) */"

        try? noContentFile.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(fileSystem).unsafeRunSyncEither()
        let newContentFile = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(newContentFile, noContentFile)
    }
    
    func testRemoveHeaderSection_IsInvalid_ReturnSameFile() {
        let fileURL = output.appendingPathComponent("TestRemoveHeaderSection_IsInvalid.swift")
        let invalidContentFile = """
                                 /* INVALID.\(Constants.headerKey)
                                        ----
                                        ----
                                 */
                                 """

        try? invalidContentFile.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(fileSystem).unsafeRunSyncEither()
        let newContentFile = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(newContentFile, invalidContentFile)
    }
    
    
    private enum Constants {
        static let headerKey = "API.CONFIG.HEADERS"
    }
}
