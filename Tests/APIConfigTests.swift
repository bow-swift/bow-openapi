//  Copyright © 2019 The Bow Authors.

import XCTest
import SwiftCheck


class APIConfigTests: XCTestCase {

    let original = API.Config(basePath: "http://test.openapi.com")
                        .append(headers: ["test": "api.config"])
                        .append(contentType: .json)
                        .appendHeader(value: "api.config.2", forKey: "test.2")
    
    
    // MARK: - copy operations
    func testCopy() {
        property("An API Config and its copy are isomorphic") <- forAll { (basePath: String, headers: [String: String]) in
            let new = API.Config(basePath: basePath).append(headers: headers)
            let copied = new.copy(basePath: self.original.basePath, headers: self.original.headers, session: self.original.session)
            return  copied == self.original
        }
    }
    
    func testCopyHeaders() {
        property("Consistent between append and copy operations") <- forAll { (headers: [String: String]) in
            let append = self.original.append(headers: headers)
            let copied = self.original.copy(headers: self.original.headers.combine(headers))
            return append == copied
        }
        
        property("Consistent between append one header and copy operations") <- forAll { (key: String, value: String) in
            let append = self.original.appendHeader(value: value, forKey: key)
            let copied = self.original.copy(headers: self.original.headers.combine([key: value]))
            return append == copied
        }
        
        property("Consistent between content-type and copy operations") <- forAll { (contentType: API.ContentType) in
            let append = self.original.append(contentType: contentType)
            let copied = self.original.copy(headers: self.original.headers.combine(contentType.headers))
            return append == copied
        }
    }
    
    // MARK: - validate auto-generated headers
    func testGeneratedHeaders() {
        property("Consistent between auto-generated header and copy operations") <- forAll { (value: String) in
            let updated = self.original.appendHeader(value: value, forKey: "Test-Token")
            let generated = self.original.appendHeader(testToken: value)
            return updated == generated
        }
    }
    
    // MARK: - properties in headers
    func testHeaders_Identity() {
        let identity = original.append(headers: [:])
        XCTAssertEqual(original, identity)
    }
    
    func testHeaders_Idempotent() {
        let apiconfig1 = original.append(headers: [:])
        let apiconfig2 = original.append(headers: [:]).append(headers: [:])
        
        XCTAssertEqual(apiconfig1, apiconfig2)
    }
    
    func testHeaders() {
        property("Property commutative in headers") <- forAll { (header1: [String: String], header2: [String: String]) in
            return self.original.append(headers: header1).append(headers: header2) ==
                   self.original.append(headers: header2).append(headers: header1)
        }
        
        property("Property associative in headers") <- forAll { (header1: [String: String], header2: [String: String], header3: [String: String]) in
            return self.original.append(headers: header1).append(headers: header2.combine(header3)) ==
                   self.original.append(headers: header1.combine(header2)).append(headers: header3)
        }
        
        property("Property distributive in headers") <- forAll { (header1: [String: String], header2: [String: String]) in
            return self.original.append(headers: header1.combine(header2)) ==
                   self.original.append(headers: header1).append(headers: header2)
        }
    }
}
