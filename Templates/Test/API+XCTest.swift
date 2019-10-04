////  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


public extension XCTest {
    func assert<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                              apiConfig: API.Config,
                              succeeds: T,
                              _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        envIO.provide(apiConfig)
             .unsafeRunSyncEither()
             .assert(success: succeeds)
    }
    
    func assert<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                              apiConfig: API.Config,
                              failures: Error,
                              _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        envIO.provide(apiConfig)
             .unsafeRunSyncEither()
             .assert(error: .other(error: Mock.Error.general))
    }
    
    func assertMalformedURL<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                          apiConfig: API.Config,
                                          _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {

        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .malformedURL(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertParsingError<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                          apiConfig: API.Config,
                                          _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .parsingError(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertBadRequest<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                        apiConfig: API.Config,
                                        _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .badRequest(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertForbidden<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                       apiConfig: API.Config,
                                        _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .forbidden(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertNotFound<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                      apiConfig: API.Config,
                                      _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .notFound(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertServerError<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                         apiConfig: API.Config,
                                         _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .serverError(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertServiceUnavailable<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                         apiConfig: API.Config,
                                         _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .serviceUnavailable(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assertUnknown<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                         apiConfig: API.Config,
                                         _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .unknown(response: httpResponse, data: data), information: information, file: file, line: line)
    }
    
    func assert<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                         apiConfig: API.Config,
                                         _ information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        
        let (response, httpResponse, data) = perform(envIO, with: apiConfig)
        response.assert(error: .unknown(response: httpResponse, data: data), information: information, file: file, line: line)
    }
}

// MARK: - helpers

typealias HTTPErrorData<T> = (response: Either<API.HTTPError, T>, httpResponse: URLResponse, data: Data)

private extension XCTest {
    func perform<T: Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>, with apiConfig: API.Config) -> HTTPErrorData<T> {
        let either = envIO.provide(apiConfig).unsafeRunSyncEither()
        let dataError = either.leftValue.dataError!
        return (response: either, httpResponse: dataError.response, data: dataError.data)
    }
}

private extension Either where A == API.HTTPError, B: Equatable {
    func assert(success expected: B, information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        fold({ error in XCTFail(information ?? "Expected successful value \(expected), but found an error: \(error).", file: file, line: line) },
             { value in XCTAssertEqual(expected, value, file: file, line: line) })
    }
}

private extension Either where A == API.HTTPError {
    func assert(error: API.HTTPError, information: String? = nil, file: StaticString = #file, line: UInt = #line) {
        fold({ err in XCTAssertEqual(error, err, file: file, line: line) },
             { value in XCTFail(information ?? "Expected error: \(error), but found successful value: \(value)") })
    }
}
