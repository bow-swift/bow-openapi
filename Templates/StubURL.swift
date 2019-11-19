//  Copyright © 2019 The Bow Authors.

import Foundation
import {{ moduleName }}

class StubURL: URLProtocol {
    private(set) static var data: Data?
    private(set) static var error: Error?
    private(set) static var statusCode: Int = 200
    
    /// Stubs methods
    class func stub(data: Data, code: Int = 200) {
        StubURL.data = data
        StubURL.statusCode = code
    }
    
    class func stub(error: Error, code: Int = 400) {
        StubURL.error = error
        StubURL.statusCode = code
    }
    
    class func stub(json: String, code: Int = 200) {
        stub(data: json.data(using: .utf8)!, code: code)
    }
    
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
