////  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects

public class APITestCase {
    
    private let apiConfig: API.Config
    
    init(apiConfig: API.Config) {
        self.apiConfig = apiConfig
    }
    
    // MARK: send
    func send<T: Codable>(request: URLRequest) -> Either<API.HTTPError, T> {
        let envIO = EnvIO<API.Config, API.HTTPError, T> { config in
            API.send(request: request, session: config.session, decoder: config.decoder)
        }
            
        return envIO.provide(self.apiConfig).unsafeRunSyncEither()
    }
}

public extension Either where A == API.HTTPError, B: Equatable {
    func assert(success expected: B, _ information: String = "", file: StaticString = #file, line: UInt = #line) {
        fold({ error in XCTFail("Expected successful value \(expected), but found an error: \(error).", file: file, line: line) },
             { value in XCTAssertEqual(expected, value, file: file, line: line) })
    }
}

public extension Either where A == API.HTTPError, B: Codable {
    func assert(error: API.HTTPError, _ information: String = "", file: StaticString = #file, line: UInt = #line) {
        fold({ err in XCTAssertEqual(error, err, file: file, line: line) },
             { value in XCTFail("Expected error: \(error), but found successful value: \(value)") })
    }
}

public extension Either where A == API.HTTPError, B == String {
    func assert(error: API.HTTPError, _ information: String = "", file: StaticString = #file, line: UInt = #line) {
        fold({ err in XCTAssertEqual(error, err, file: file, line: line) },
             { value in XCTFail("Expected error: \(error), but found successful value: \(value)") })
    }
}
