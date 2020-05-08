//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects
@testable import OpenApiGenerator


class GeneratorSwaggerClientTests: XCTestCase {
    private let sut = SwaggerClientGenerator()
    private let fileSystem = MacFileSystem()
    private let output = URL.temp(subfolder: String(#file).filename.removeExtension)
    private lazy var outputFile = output.parent.appendingPathComponent("Test_Output.swift")
    private let template = URL.templates
    
    private func env(fileSystem: FileSystem) -> Environment {
        .init(logPath: "", fileSystem: fileSystem, generator: ClientGeneratorMock(shouldFail: false))
    }
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.createDirectoryIO(at: output, withIntermediateDirectories: true).unsafeRunSync()
        try? "".write(to: outputFile, atomically: true, encoding: .utf8)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItemIO(at: output).unsafeRunSync()
        super.tearDown()
    }
    
    
    // MARK: - Headers operations
    
    func testRemoveHeaderSection_ReturnFileUpdated() {
        let fileURL = output.appendingPathComponent("TestRemoveHeaderSection_Valid.swift")
        let contentFile = """
                          /* \(Constants.headerKey)
                                ----
                                ----
                          */
                          """

        try? contentFile.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
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
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let newContentFile = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(newContentFile, extraContent)
    }
    
    func testRemoveHeaderSection_WithoutContent_ReturnSameFile() {
        let fileURL = output.appendingPathComponent("TestRemoveHeaderSection_WithoutContent.swift")
        let noContentFile = "/* \(Constants.headerKey) */"

        try? noContentFile.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
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
        let either = sut.removeHeadersDefinition(filesAt: output.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let newContentFile = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(newContentFile, invalidContentFile)
    }
    
    func testRenderHelpersForHeaders_ValidHeader_RenderHelper() {
        let fileURL = output.appendingPathComponent("TestRenderHelpersForHeaders_ValidHeaderSection.swift")
        let headerSection = """
                            /* \(Constants.headerKey)
                            headerKey:headerType:headerName
                            */
                            """
        let expected = """
                           public func appendingHeader(headerKey: headerType) -> API.Config {
                               self.copy(headers: self.headers.combine([\"headerName\": headerKey]))
                           }
                       """

        try? headerSection.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.renderHelpersForHeaders(filesAt: output.path, inFile: outputFile.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let rendered = try! String(contentsOf: outputFile)
        
        XCTAssert(either.isRight)
        XCTAssert(rendered.contains(expected))
    }
    
    func testRenderHelpersForHeaders_DifferentsHeaders_RenderMultiplesHelpers() {
        let fileURL = output.appendingPathComponent("TestRenderHelpersForHeaders_DifferentsHeaders.swift")
        let headerSection = """
                            /* \(Constants.headerKey)
                            headerKey:headerType:headerName
                            headerKey2:headerType2:headerName2
                            */
                            """
        let expected1 = """
                            public func appendingHeader(headerKey2: headerType2) -> API.Config {
                                self.copy(headers: self.headers.combine([\"headerName2\": headerKey2]))
                            }
                        """
        let expected2 = """
                            public func appendingHeader(headerKey2: headerType2) -> API.Config {
                                self.copy(headers: self.headers.combine([\"headerName2\": headerKey2]))
                            }
                        """

        try? headerSection.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.renderHelpersForHeaders(filesAt: output.path, inFile: outputFile.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let rendered = try! String(contentsOf: outputFile)
        
        XCTAssert(either.isRight)
        XCTAssert(rendered.contains(expected1))
        XCTAssert(rendered.contains(expected2))
    }
    
    func testRenderHelpersForHeaders_MultiplesSameHeaders_RenderOnlyHelper() {
        let fileURL = output.appendingPathComponent("RenderHelpersForHeaders_MultiplesSameHeaders.swift")
        let headerSection = """
                            /* \(Constants.headerKey)
                            headerKey:headerType:headerName
                            headerKey:headerType:headerName
                            headerKey:headerType:headerName
                            headerKey:headerType:headerName
                            headerKey:headerType:headerName
                            */
                            """
        let expected = """
                           public func appendingHeader(headerKey: headerType) -> API.Config {
                               self.copy(headers: self.headers.combine([\"headerName\": headerKey]))
                           }
                       """

        try? headerSection.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.renderHelpersForHeaders(filesAt: output.path, inFile: outputFile.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let rendered = try! String(contentsOf: outputFile)
        
        XCTAssert(either.isRight)
        XCTAssert(rendered.contains(expected))
    }
    
    func testRenderHelpersForHeaders_MultiplesSameHeadersInDifferentsFiles_RenderOnlyHelper() {
        let file1URL = output.appendingPathComponent("TestRenderHelpersForHeaders_ValidHeaderSection1.swift")
        let file2URL = output.appendingPathComponent("TestRenderHelpersForHeaders_ValidHeaderSection2.swift")
        let file3URL = output.appendingPathComponent("TestRenderHelpersForHeaders_ValidHeaderSection3.swift")
        let headerSection = """
                            /* \(Constants.headerKey)
                            headerKey:headerType:headerName
                            */
                            """
        let expected = """
                           public func appendingHeader(headerKey: headerType) -> API.Config {
                               self.copy(headers: self.headers.combine([\"headerName\": headerKey]))
                           }
                       """

        try? headerSection.write(to: file1URL, atomically: true, encoding: .utf8)
        try? headerSection.write(to: file2URL, atomically: true, encoding: .utf8)
        try? headerSection.write(to: file3URL, atomically: true, encoding: .utf8)
        let either = sut.renderHelpersForHeaders(filesAt: output.path, inFile: outputFile.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let rendered = try! String(contentsOf: outputFile)
        
        XCTAssert(either.isRight)
        XCTAssert(rendered.contains(expected))
    }
    
    // MARK: - Fix signature: parameters
    
    func testFixSignatureParameters_WhenNeedFix_ReturnValidSignature() {
        let fileURL = output.appendingPathComponent("TestFixSignatureParameters_WhenNeedFix.swift")
        let invalidSignature = """
                               func params(,invalid: String) {}
                               func params(valid: String) {}
                               """
        let expected = """
                       func params(invalid: String) {}
                       func params(valid: String) {}
                       """

        try? invalidSignature.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.fixSignatureParameters(filesAt: output.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let rendered = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(rendered, expected)
    }
    
    func testFixSignatureParameters_WhenNotNeedFix_ReturnValidSignature() {
        let fileURL = output.appendingPathComponent("TestFixSignatureParameters_WhenNotNeedFix.swift")
        let validSignature = """
                             func params(valid1: String) {}
                             func params(valid2: String) {}
                             """

        try? validSignature.write(to: fileURL, atomically: true, encoding: .utf8)
        let either = sut.fixSignatureParameters(filesAt: output.path).provide(env(fileSystem: fileSystem)).unsafeRunSyncEither()
        let rendered = try! String(contentsOf: fileURL)
        
        XCTAssert(either.isRight)
        XCTAssertEqual(rendered, validSignature)
    }
    
    
    private enum Constants {
        static let headerKey = "API.CONFIG.HEADERS"
    }
}
