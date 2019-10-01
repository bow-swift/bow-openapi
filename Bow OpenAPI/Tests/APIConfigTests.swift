//  Copyright © 2019 The Bow Authors.

import XCTest
import SwiftCheck

class APIConfigTests: XCTestCase {

    func testCopy() {
        let apiConfig = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])

        property("Update an API.Config with differents properties") <- forAll { (basePath: String?, headers: [String: String]?) in
            let new = API.Config(basePath: basePath ?? apiConfig.basePath).append(headers: headers ?? apiConfig.headers)
            let copied = apiConfig.copy(basePath: basePath, headers: headers)
            return  copied == new
        }
    }
    
    func testCopyHeaders() {
        let apiConfig = API.Config(basePath: "http://test.openapi.com")
                            .append(headers: ["test": "api.config"])
                            .append(contentType: .json)
                            .appendHeader(value: "api.config.2", forKey: "test.2")

        property("Update an API.Config with differents headers") <- forAll { (headers: [String: String]?) in
            let new = API.Config(basePath: apiConfig.basePath).append(headers: apiConfig.headers).append(headers: headers ?? [:])
            let copied = apiConfig.copy(headers: headers.flatMap { apiConfig.headers.combine($0) })
            return  copied == new
        }
        
        property("Update an API.Config with a new header") <- forAll { (value: String, key: String) in
            let new = API.Config(basePath: apiConfig.basePath).append(headers: apiConfig.headers).appendHeader(value: value, forKey: key)
            let copied = apiConfig.copy(headers: apiConfig.headers.combine([key: value]))
            return  copied == new
        }
        
        property("Update an API.Config with a new content type") <- forAll { (contentType: API.ContentType) in
            let new = API.Config(basePath: apiConfig.basePath).append(headers: apiConfig.headers).append(headers: contentType.headers)
            let copied = apiConfig.append(contentType: contentType)
            return copied == new
        }
    }
    
    func testGeneratedHeaders() {
        let apiConfig = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])
        
        property("Check generated headers") <- forAll { (value: String) in
            let updated = apiConfig.appendHeader(value: value, forKey: "Test-Token")
            let generated = apiConfig.appendHeader(testToken: value)
            return updated == generated
        }
    }
}
