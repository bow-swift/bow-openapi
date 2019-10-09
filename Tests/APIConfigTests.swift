//  Copyright © 2019 The Bow Authors.

import XCTest
import SwiftCheck


class APIConfigTests: XCTestCase {

    // MARK: - copy operations
    func testCopy() {
        property("An API config and its copy are equal") <- forAll(API.Config.arbitraryWithHeaders) { (config: API.Config) in
            return config == config.copy()
        }
    }
    
    func testCopyHeaders() {
        property("Appending headers using `append(headers:)` with same key overrides value") <- forAll { (config: API.Config, key: String, value1: String, value2: String) in
            let x = config.append(headers: [key: value1]).append(headers: [key: value2])
            let y = config.append(headers: [key: value2])
            return x == y
        }
        
        property("Appending headers using `appendHeader(value:forKey:)` with same key overrides value") <- forAll { (config: API.Config, key: String, value1: String, value2: String) in
            let x = config.appendHeader(value: value1, forKey: key).appendHeader(value: value2, forKey: key)
            let y = config.appendHeader(value: value2, forKey: key)
            return x == y
        }
    }
    
    // MARK: - properties in headers
    func testHeaders_Identity() {
        property("Identity") <- forAll { (config: API.Config) in
            return config == config.append(headers: [:])
        }
    }
    
    func testHeaders_Idempotent() {
        property("Idempotence") <- forAll { (config: API.Config, headers: [String: String]) in
            let x = config.append(headers: headers)
            let y = config.append(headers: headers).append(headers: headers)
            
            return x == y
        }
    }
    
    let headerGen = [String: String].arbitrary
    func testHeaders() {
        property("Property associative in headers") <- forAll(API.Config.arbitraryWithHeaders, self.headerGen, self.headerGen, self.headerGen) { (config: API.Config, header1: [String: String], header2: [String: String], header3: [String: String]) in
            return config.append(headers: header1).append(headers: header2.combine(header3)) ==
                   config.append(headers: header1.combine(header2)).append(headers: header3)
        }
    }
}
