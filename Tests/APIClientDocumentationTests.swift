//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting

class APIClientDocumentationTests: XCTestCase {

    func testRequestDocumented() {
        assertSnapshot(matching: URL.schemas.file(.requestDocumentation), as: .generated(file: "RequestDocAPI.swift"))
    }
    
    func testModelDocumented() {
        assertSnapshot(matching: URL.schemas.file(.modelDocumentation), as: .generated(file: "PetDocumented.swift"))
    }
}
