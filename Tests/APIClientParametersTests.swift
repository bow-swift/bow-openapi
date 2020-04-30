//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting

class APIClientParametersTests: XCTestCase {

    func testRequestWithQueryParam_URLComponentsAndQueryItems() {
        assertSnapshot(matching: URL.schemas.file(.queryParam), as: .generated(file: "DefaultAPI.swift"))
    }

    func testRequestWithPathParam_BuildRequestPath() {
        assertSnapshot(matching: URL.schemas.file(.pathParam), as: .generated(file: "DefaultAPI.swift"))
    }

    func testRequestWithHeaderParam_GenerateHelperMethod() {
        assertSnapshot(matching: URL.schemas.file(.headerParam), as: .generated(file: "APIs.swift"))
    }

    func testRequestWithBodyParam_BuildRequestPath() {
        assertSnapshot(matching: URL.schemas.file(.bodyParam), as: .generated(file: "DefaultAPI.swift"))
    }

    func testRequestWithQueryParamOptional_URLComponentsAndQueryItems() {
        assertSnapshot(matching: URL.schemas.file(.queryParamOptional), as: .generated(file: "DefaultAPI.swift"))
    }

    func testRequestWithPathParamOptional_BuildRequestPathNoOptional() {
        assertSnapshot(matching: URL.schemas.file(.pathParamOptional), as: .generated(file: "DefaultAPI.swift"))
    }

    func testRequestWithHeaderParamOptional_GenerateHelperMethodNoOptional() {
        assertSnapshot(matching: URL.schemas.file(.headerParamOptional), as: .generated(file: "APIs.swift"))
    }
    
    func testRequestWithContentType_ApplicationJson() {
        assertSnapshot(matching: URL.schemas.file(.contentTypeJSON), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestWithContentType_WWWFormURLEncoded() {
        assertSnapshot(matching: URL.schemas.file(.contentTypeWWWFormURLEncoded), as: .generated(file: "DefaultAPI.swift"))
    }
    
    func testRequestWithBodyParamOptional_BuildRequestPath() {
        assertSnapshot(matching: URL.schemas.file(.bodyParamOptional), as: .generated(file: "DefaultAPI.swift"))
    }
}
