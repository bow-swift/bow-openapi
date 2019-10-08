////  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


public extension XCTest {
    
    func assert<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                              withConfig apiConfig: API.Config,
                              succeeds: T,
                              _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        envIO.provide(apiConfig)
             .unsafeRunSyncEither()
             .assert(success: succeeds, information: information, file: file, line: line)
    }
    
    func assert<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                              withConfig apiConfig: API.Config,
                              fails: HTTPErrorTest,
                              _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        envIO.provide(apiConfig)
             .unsafeRunSyncEither()
             .assert(error: fails, information: information, file: file, line: line)
    }
}


// MARK: helpers

fileprivate extension Either where A == API.HTTPError, B: Equatable {
    func assert(success expected: B, information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        fold({ error in XCTFail(information ?? "Expected successful value \(expected), but found an error: \(error).", file: file, line: line) },
             { value in XCTAssertEqual(expected, value, file: file, line: line) })
    }
}

fileprivate extension Either where A == API.HTTPError {
    func assert(error: HTTPErrorTest, information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        fold({ err in XCTAssertEqual(error.apiError(withData: err), err, file: file, line: line) },
             { value in XCTFail(information ?? "Expected error: \(error), but found successful value: \(value)") })
    }
}
