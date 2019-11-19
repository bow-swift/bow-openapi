//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow

struct StubbedResponse {
    let statusCode: Int
    let content: Either<Error, Data>
    
    init(data: Data, statusCode: Int = 200) {
        self.statusCode = statusCode
        self.content = .right(data)
    }
    
    init(error: Error, statusCode: Int = 404) {
        self.statusCode = statusCode
        self.content = .left(error)
    }
}

class StubURL: URLProtocol {
    static let anyEndpoint = ">>>ANY-ENDPOINT<<<"
    private static var stubs: [String: [StubbedResponse]] = [:]
    
    private static func stub(response: StubbedResponse, for endpoint: String) {
        if let responses = stubs[endpoint] {
            stubs[endpoint] = responses + [response]
        } else {
            stubs[endpoint] = [response]
        }
    }
    
    /// Stub methods
    static func stub(data: Data, code: Int = 200, endpoint: String = anyEndpoint) {
        stub(response: StubbedResponse(data: data, statusCode: code),
             for: endpoint)
    }
    
    static func stub(error: Error, code: Int = 404, endpoint: String = anyEndpoint) {
        stub(response: StubbedResponse(error: error, statusCode: code),
             for: endpoint)
    }
    
    static func stub(json: String, code: Int = 200, endpoint: String = anyEndpoint) {
        stub(response: StubbedResponse(data: json.data(using: .utf8)!),
             for: endpoint)
    }
    
    static func stub(contentsOfFile url: URL, code: Int = 200, endpoint: String = anyEndpoint) {
        let content = try! String(contentsOf: url, encoding: .utf8)
        stub(json: content, code: code, endpoint: endpoint)
    }
    
    /// Clears all stubs.
    static func reset() {
        stubs = [:]
    }
    
    static func response(for request: URLRequest) -> StubbedResponse? {
        if let url = request.url?.absoluteString {
            for endpoint in stubs {
                if url.hasSuffix(endpoint.key) {
                    return consume(endpoint.key)
                }
            }
        }
        return consume(anyEndpoint)
    }
    
    static func consume(_ endpoint: String) -> StubbedResponse? {
        let queue = stubs[endpoint]
        let response = queue?.first
        stubs[endpoint] = Array(queue?.dropFirst() ?? [])
        return response
    }
    
    // MARK: - URLProtocol methods
    override static func canInit(with request:URLRequest) -> Bool {
        return true
    }
    
    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = StubURL.response(for: request) else {
            fatalError("No response stubbed for request: \(request)")
        }
        
        let header = request.allHTTPHeaderFields
        
        let response = HTTPURLResponse(url: request.url!, statusCode: stub.statusCode, httpVersion: nil, headerFields: header)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        stub.content.fold(
            { error in
                client?.urlProtocol(self, didFailWithError: error)
                return
            },
            { data in
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
                return
            })
    }
    
    override func stopLoading() { }
}
