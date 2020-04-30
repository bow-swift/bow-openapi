//  Copyright © 2019 The Bow Authors.

import XCTest
import SwiftCheck
import FixturesAPI


class APIConfigTests: XCTestCase {

    // MARK: - copy operations
    func testCopy() {
        property("An API config and its copy are equal") <- forAll(API.Config.arbitraryWithHeaders) { (config: API.Config) in
            return config == config.copy()
        }
    }
    
    func testCopyHeaders() {
        property("Appending headers using `append(headers:)` with same key overrides value") <- forAll { (config: API.Config, key: String, value1: String, value2: String) in
            let x = config.appending(headers: [key: value1]).appending(headers: [key: value2])
            let y = config.appending(headers: [key: value2])
            return x == y
        }
        
        property("Appending headers using `appendHeader(value:forKey:)` with same key overrides value") <- forAll { (config: API.Config, key: String, value1: String, value2: String) in
            let x = config.appendingHeader(value: value1, forKey: key).appendingHeader(value: value2, forKey: key)
            let y = config.appendingHeader(value: value2, forKey: key)
            return x == y
        }
    }
    
    // MARK: - properties in headers
    func testHeaders_Identity() {
        property("Identity") <- forAll { (config: API.Config) in
            return config == config.appending(headers: [:])
        }
    }
    
    func testHeaders_Idempotent() {
        property("Idempotence") <- forAll { (config: API.Config, headers: [String: String]) in
            let x = config.appending(headers: headers)
            let y = config.appending(headers: headers).appending(headers: headers)
            
            return x == y
        }
    }
    
    let headerGen = [String: String].arbitrary
    func testHeaders() {
        property("Property associative in headers") <- forAll(API.Config.arbitraryWithHeaders, self.headerGen, self.headerGen, self.headerGen) { (config: API.Config, header1: [String: String], header2: [String: String], header3: [String: String]) in
            return config.appending(headers: header1).appending(headers: header2.combine(header3)) ==
                   config.appending(headers: header1.combine(header2)).appending(headers: header3)
        }
    }
}
