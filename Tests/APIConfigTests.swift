//  Copyright © 2019 The Bow Authors.

import XCTest
import Foundation
import SwiftCheck

class APIConfigTests: XCTestCase {

    // MARK: - copy operations
    func testCopy() {
        let original = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])

        property("An API Config and its copy are isomorphic") <- forAll { (basePath: String, headers: [String: String]) in
            let new = API.Config(basePath: basePath).append(headers: headers)
            let copied = new.copy(basePath: original.basePath, headers: original.headers, session: original.session)
            return  copied == original
        }
    }
    
    func testCopyHeaders() {
        let original = API.Config(basePath: "http://test.openapi.com")
                            .append(headers: ["test": "api.config"])
                            .append(contentType: .json)
                            .appendHeader(value: "api.config.2", forKey: "test.2")

        property("Consistent between append and copy operations") <- forAll { (headers: [String: String]) in
            let append = original.append(headers: headers)
            let copied = original.copy(headers: original.headers.combine(headers))
            return append == copied
        }
        
        property("Consistent between append one header and copy operations") <- forAll { (key: String, value: String) in
            let append = original.appendHeader(value: value, forKey: key)
            let copied = original.copy(headers: original.headers.combine([key: value]))
            return append == copied
        }
        
        property("Consistent between content-type and copy operations") <- forAll { (contentType: API.ContentType) in
            let append = original.append(contentType: contentType)
            let copied = original.copy(headers: original.headers.combine(contentType.headers))
            return append == copied
        }
    }
    
    // MARK: - validate auto-generated headers
    func testGeneratedHeaders() {
        let original = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])
        
        property("Consistent between auto-generated header and copy operations") <- forAll { (value: String) in
            let updated = original.appendHeader(value: value, forKey: "Test-Token")
            let generated = original.appendHeader(testToken: value)
            return updated == generated
        }
    }
    
    // MARK: - properties in headers
    func testHeaders_Identity() {
        let original = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])
        let identity = original.append(headers: [:])
        
        XCTAssertEqual(original, identity)
    }
    
    func testHeaders_Idempotent() {
        let original = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])
        let apiconfig1 = original.append(headers: [:])
        let apiconfig2 = original.append(headers: [:]).append(headers: [:])
        
        XCTAssertEqual(apiconfig1, apiconfig2)
    }
    
    func testHeaders() {
        let original = API.Config(basePath: "http://test.openapi.com").append(headers: ["test": "api.config"])

        property("Property commutative in headers") <- forAll { (header1: [String: String], header2: [String: String]) in
            return original.append(headers: header1).append(headers: header2) ==
                   original.append(headers: header2).append(headers: header1)
        }
        
        property("Property associative in headers") <- forAll { (header1: [String: String], header2: [String: String], header3: [String: String]) in
            return original.append(headers: header1).append(headers: header2.combine(header3)) ==
                   original.append(headers: header1.combine(header2)).append(headers: header3)
        }
        
        property("Property distributive in headers") <- forAll { (header1: [String: String], header2: [String: String]) in
            return original.append(headers: header1.combine(header2)) ==
                   original.append(headers: header1).append(headers: header2)
        }
    }
}
