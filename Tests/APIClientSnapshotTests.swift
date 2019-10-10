//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting


class APIClientSnapshotTests: XCTestCase {
    
    // MARK: generated api-client
    func testNoDefinedTags_GenerateDefaultAPI() {
        assertSnapshot(matching: URL.schemas.file(.noDefinedTags), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testDefinedTags_GenerateTagAPI() {
        assertSnapshot(matching: URL.schemas.file(.tags), as: .generated(file: "PetAPI.swift"))
    }
    
    func testApiClientGenerated_SwaggerSchema() {
        assertSnapshot(matching: URL.schemas.file(.swagger), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testApiClientGenerated_OpenAPISchema() {
        assertSnapshot(matching: URL.schemas.file(.openapi), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testApiClientGenerated_JSONSchema() {
        assertSnapshot(matching: URL.schemas.file(.json), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testApiClientGenerated_YAMLSchema() {
        assertSnapshot(matching: URL.schemas.file(.yaml), as: .generated(file: "DefaultAPI.swift"))
    }
    
    // MARK: api-client operations
    func testNoDefinedOperationId_OperationUsingEndpoint() {
        assertSnapshot(matching: URL.schemas.file(.noDefinedOperationId), as: .generated(file: "DefaultAPI.swift"))
    }
    
    // MARK: api-client http methods
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
    
    // MARK: api-client parameters
    func testRequestWithQueryParam_URLComponentsAndQueryItems() {
        assertSnapshot(matching: URL.schemas.file(.queryParam), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestWithPathParam_BuildRequestPath() {
        assertSnapshot(matching: URL.schemas.file(.pathParam), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestWithHeaderParam_GenerateHelpersMethods() {
        assertSnapshot(matching: URL.schemas.file(.headerParam), as: .generated(file: "APIs.swift"))
    }
    
    func testRequestWithBodyParam_BuildRequestPath() {
        assertSnapshot(matching: URL.schemas.file(.bodyParam), as: .generated(file: "DefaultAPI.swift"))
    }
    
    // MARK: models
    func testRequestWithReference_BuildModel() {
        assertSnapshot(matching: URL.schemas.file(.requestWithReference), as: .generated(file: "Pet.swift"))
    }
}
