//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting


class APIClientGeneratorTests: XCTestCase {
    
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
    
    func testApiClientGenerated_OpenAPIAndJSONSchema_WithSameSpecification_GenerateSameAPIClient() {
        let apiClient = "DefaultAPI.swift"
        let generator = Snapshotting.generated(file: apiClient)
        
        let openAPI = generator.snapshot(URL.schemas.file(.openapi))
        let swagger = generator.snapshot(URL.schemas.file(.swagger))
        
        var snapshot1 = ""
        var snapshot2 = ""
        let expectation = self.expectation(description: "Expectation: specification from openAPI and swagger")
        
        openAPI.run { snapshotOpenAPI in
            swagger.run { snapshotSwagger in
                snapshot1 = snapshotOpenAPI
                snapshot2 = snapshotSwagger
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30)
        XCTAssert(snapshot1 == snapshot2 && !snapshot1.isEmpty)
    }
    
    func testApiClientGenerated_JSONSchema() {
        assertSnapshot(matching: URL.schemas.file(.json), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testApiClientGenerated_YAMLSchema() {
        assertSnapshot(matching: URL.schemas.file(.yaml), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testApiClientGenerated_JSONAndYAML_WithSameSpecification_GenerateSameAPIClient() {
        let apiClient = "DefaultAPI.swift"
        let generator = Snapshotting.generated(file: apiClient)
        
        let json = generator.snapshot(URL.schemas.file(.json))
        let yaml = generator.snapshot(URL.schemas.file(.yaml))
        
        var snapshot1 = ""
        var snapshot2 = ""
        let expectation = self.expectation(description: "Expectation: specification with JSON and YAML")
        
        json.run { snapshotJSON in
            yaml.run { snapshotYAML in
                snapshot1 = snapshotJSON
                snapshot2 = snapshotYAML
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30)
        XCTAssert(snapshot1 == snapshot2 && !snapshot1.isEmpty)
    }
}
