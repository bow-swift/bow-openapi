//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting

class APIClientHttpOperationTests: XCTestCase {
    
    func testNoDefinedOperationId_OperationUsingEndpointNaming() {
        assertSnapshot(matching: URL.schemas.file(.noDefinedOperationId), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestPOST() {
        assertSnapshot(matching: URL.schemas.file(.post), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestGET() {
        assertSnapshot(matching: URL.schemas.file(.get), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestPUT() {
        assertSnapshot(matching: URL.schemas.file(.put), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestDELETE() {
        assertSnapshot(matching: URL.schemas.file(.delete), as: .generated(file: "DefaultAPI.swift"))
    }
}
