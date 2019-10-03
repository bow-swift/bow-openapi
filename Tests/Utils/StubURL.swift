//  Copyright © 2019 The Bow Authors.

import Foundation


class StubURL: URLProtocol {
    
    private(set) static var data: Data?
    private(set) static var error: Error?
    private(set) static var statusCode: Int = 200
    
    /// Stubs data to respond the next HTTP request with.
    /// - Parameter data: Contents of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    class func stub(data: Data, code: Int = 200) {
        StubURL.data = data
        StubURL.statusCode = code
    }
    
    /// Stubs error to respond the next HTTP request with.
    /// - Parameter error: error of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 400.
    class func stub(error: Error, code: Int = 400) {
        StubURL.error = error
        StubURL.statusCode = code
    }
    
    /// Stubs a string in JSON format to respond the next HTTP request with.
    /// - Parameter json: A string in JSON format with the contents of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    class func stub(json: String, code: Int = 200) {
        stub(data: json.data(using: .utf8)!, code: code)
    }
    
    /// Stubs the contents of a file to respond the next HTTP request with.
    /// - Parameter url: URL of the file containing the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    class func stub(contentsOfFile url: URL, code: Int = 200) {
        let content = try! String(contentsOf: url, encoding: .utf8)
        stub(json: content, code: code)
    }
    
    /// Reset the stub to default values: data to nil, error to nil and status code to 200.
    class func reset() {
        StubURL.data = nil
        StubURL.error = nil
        StubURL.statusCode = 200
    }
    
    // MARK: - URLProtocol methods
    override class func canInit(with request:URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let header = request.allHTTPHeaderFields
        let response = HTTPURLResponse(url: request.url!, statusCode: StubURL.statusCode, httpVersion: nil, headerFields: header)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let error = StubURL.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocol(self, didLoad: StubURL.data ?? Data())
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() { }
}
