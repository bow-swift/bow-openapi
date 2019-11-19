//  Copyright © 2019 The Bow Authors.

import Foundation
import {{ moduleName }}

public extension API.Config {
    
    /// Stubs data to respond the next HTTP request with.
    /// - Parameter data: Contents of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    func stub(data: Data, code: Int = 200) -> API.Config {
        StubURL.reset()
        StubURL.stub(data: data, code: code)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs data to respond the next HTTP request with.
    /// - Parameter dataRaw: Contents of the response as String to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    func stub(dataRaw raw: String, code: Int = 200) -> API.Config {
        StubURL.reset()
        StubURL.stub(data: raw.data(using: .utf8)!, code: code)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs error to respond the next HTTP request with.
    /// - Parameter error: error of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 400.
    func stub(error: Error, code: Int = 400) -> API.Config {
        StubURL.reset()
        StubURL.stub(error: error, code: code)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs a string in JSON format to respond the next HTTP request with.
    /// - Parameter json: A string in JSON format with the contents of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    func stub(json: String, code: Int = 200) -> API.Config {
        StubURL.reset()
        StubURL.stub(json: json, code: code)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs the contents of a file to respond the next HTTP request with.
    /// - Parameter url: URL of the file containing the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    func stub(contentsOfFile url: URL, code: Int = 200) -> API.Config {
        StubURL.reset()
        StubURL.stub(contentsOfFile: url, code: code)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
}


private extension URLSessionConfiguration {
    static var testing: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [StubURL.self] as [AnyClass]
        
        return configuration
    }
}
