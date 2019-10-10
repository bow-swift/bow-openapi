//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting


class APIClientGeneratedTests: XCTestCase {
    
    // MARK: generated api-client
    func testNoDefinedTags_GenerateDefaultAPI() {
        assertSnapshot(matching: URL.schemes.file(.noDefinedTags), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testDefinedTags_GenerateTagAPI() {
        assertSnapshot(matching: URL.schemes.file(.tags), as: .generated(file: "PetAPI.swift"))
    }
    
    // MARK: api-client operations
    func testNoDefinedOperationId_OperationUsingEndpoint() {
        assertSnapshot(matching: URL.schemes.file(.noDefinedOperationId), as: .generated(file: "DefaultAPI.swift"))
    }
    
    // MARK: api-client http methods
    func testRequestPOST() {
        assertSnapshot(matching: URL.schemes.file(.post), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestGET() {
        assertSnapshot(matching: URL.schemes.file(.get), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestPUT() {
        assertSnapshot(matching: URL.schemes.file(.put), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestDELETE() {
        assertSnapshot(matching: URL.schemes.file(.delete), as: .generated(file: "DefaultAPI.swift"))
    }
    
    // MARK: api-client parameters
    func testRequestWithQueryParam_URLComponentsAndQueryItems() {
        assertSnapshot(matching: URL.schemes.file(.queryParam), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestWithPathParam_BuildRequestPath() {
        assertSnapshot(matching: URL.schemes.file(.pathParam), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestWithHeaderParam_GenerateHelpersMethods() {
        assertSnapshot(matching: URL.schemes.file(.headerParam), as: .generated(file: "APIs.swift"))
    }
    
    func testRequestWithBodyParam_BuildRequestPath() {
        assertSnapshot(matching: URL.schemes.file(.bodyParam), as: .generated(file: "DefaultAPI.swift"))
    }
}
