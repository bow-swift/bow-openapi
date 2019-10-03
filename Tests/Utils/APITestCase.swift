////  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


class APITestCase: XCTestCase {
    private var decoder: ResponseDecoder = JSONDecoder()
    private var protocolClasses: StubURL? = nil
    var response: HTTPURLResponse? = nil
    
    override func tearDown() {
        StubURL.reset()
        super.tearDown()
    }
    
    
    // MARK: stub operations
    func stub(data: Data, decoder: ResponseDecoder = JSONDecoder(), code: Int = 200) {
        self.decoder = decoder
        StubURL.stub(data: data, code: code)
    }
    
    func stub(error: Error, decoder: ResponseDecoder = JSONDecoder(), code: Int = 400) {
        self.decoder = decoder
        StubURL.stub(error: error, code: code)
    }
    
    func stub(dataRaw raw: String, decoder: ResponseDecoder = StringUTF8Decoder(), code: Int = 200) {
        self.decoder = decoder
        StubURL.stub(data: raw.data(using: .utf8)!, code: code)
    }
    
    func stub(json: String, decoder: ResponseDecoder = JSONDecoder(), code: Int = 200) {
        self.decoder = decoder
        StubURL.stub(json: json, code: code)
    }
    
    func stub(contentsOfFile url: URL, decoder: ResponseDecoder = JSONDecoder(), code: Int = 200) {
        self.decoder = decoder
        StubURL.stub(contentsOfFile: url, code: code)
    }
    
    
    // MARK: send
    func send<T: Codable>(request: URLRequest, session: URLSession = Mock.URLSessionProvider.default, file: StaticString = #file, line: UInt = #line) -> Either<API.HTTPError, T> {
        response = HTTPURLResponse(url: request.url!, statusCode: StubURL.statusCode, httpVersion: nil, headerFields: request.allHTTPHeaderFields)!
        return API.Helper.send(request: request, session: session, decoder: decoder)
                         .unsafeRunSyncEither()
    }
    
    
    // MARK: asserts
    func assertSuccess<T: Equatable>(response either: Either<API.HTTPError, T>, expected: T, _ information: String = "", file: StaticString = #file, line: UInt = #line) {
        either.fold({ error in XCTFail("Expected successful value \(expected), but found an error: \(error).", file: file, line: line) },
                    { value in XCTAssertEqual(expected, value, file: file, line: line) })
    }
    
    func assertFailure<T: Codable>(response either: Either<API.HTTPError, T>, expected error: API.HTTPError, _ information: String = "", file: StaticString = #file, line: UInt = #line) {
        either.fold({ err in XCTAssertEqual(error, err, file: file, line: line) },
                    { value in XCTFail("Expected error: \(error), but found successful value: \(value)") })
    }
}
