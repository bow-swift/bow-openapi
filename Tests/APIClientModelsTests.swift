//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting

class APIClientModelsTests: XCTestCase {
    
    func testRequestWithPetReference_BuildPetModel() {
        assertSnapshot(matching: URL.schemas.file(.referenceModel), as: .generated(file: "Pet.swift"))
    }
    
    func testModelDefinition_BuildPetModel() {
        assertSnapshot(matching: URL.schemas.file(.model), as: .generated(file: "Pet.swift"))
    }
    
    func testModelDefinitionOptional_BuildModelWithOptionals() {
        assertSnapshot(matching: URL.schemas.file(.modelOptional), as: .generated(file: "Pet.swift"))
    }
    
    func testModelWithReferences() {
        assertSnapshot(matching: URL.schemas.file(.modelWithRefs), as: .generated(file: "Pet.swift"))
    }
    
    func testModelInlineInRequest() {
        assertSnapshot(matching: URL.schemas.file(.modelInline), as: .generated(file: "InlineAPI.swift"))
    }
    
    func testModelInResponse_APIClient() {
        assertSnapshot(matching: URL.schemas.file(.responseWithModel), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testModelInResponse_Model() {
        assertSnapshot(matching: URL.schemas.file(.responseWithModel), as: .generated(file: "Pet.swift"))
    }
}
