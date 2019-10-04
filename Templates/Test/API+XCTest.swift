////  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


extension Either where A == API.HTTPError, B: Equatable {
    func assert(success expected: B, _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        fold({ error in XCTFail(information ?? "Expected successful value \(expected), but found an error: \(error).", file: file, line: line) },
             { value in XCTAssertEqual(expected, value, file: file, line: line) })
    }
}

extension Either where A == API.HTTPError {
    func assert(error: API.HTTPError, _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        fold({ err in XCTAssertEqual(error, err, file: file, line: line) },
             { value in XCTFail(information ?? "Expected error: \(error), but found successful value: \(value)") })
    }
}
