//  Copyright © 2019 The Bow Authors.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import {{ moduleName }}

public extension API.Config {
    
    /// Stubs data to respond the next HTTP request with.
    /// - Parameter data: Contents of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
    func stub(data: Data, code: Int = 200, endpoint: String? = nil) -> API.Config {
        StubURL.stub(data: data, code: code, endpoint: endpoint ?? StubURL.anyEndpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs data to respond the next HTTP request with.
    /// - Parameter dataRaw: Contents of the response as String to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
    func stub(dataRaw raw: String, code: Int = 200, endpoint: String? = nil) -> API.Config {
        StubURL.stub(data: raw.data(using: .utf8)!, code: code, endpoint: endpoint ?? StubURL.anyEndpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs error to respond the next HTTP request with.
    /// - Parameter error: error of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 400.
    /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
    func stub(error: Error, code: Int = 400, endpoint: String? = nil) -> API.Config {
        StubURL.stub(error: error, code: code, endpoint: endpoint ?? StubURL.anyEndpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs a string in JSON format to respond the next HTTP request with.
    /// - Parameter json: A string in JSON format with the contents of the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
    func stub(json: String, code: Int = 200, endpoint: String? = nil) -> API.Config {
        StubURL.stub(json: json, code: code, endpoint: endpoint ?? StubURL.anyEndpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Stubs the contents of a file to respond the next HTTP request with.
    /// - Parameter url: URL of the file containing the response to the next request.
    /// - Parameter code: HTTP status code for the response. Defaults to 200.
    /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
    func stub(contentsOfFile url: URL, code: Int = 200, endpoint: String? = nil) -> API.Config {
        StubURL.stub(contentsOfFile: url, code: code, endpoint: endpoint ?? StubURL.anyEndpoint)
        return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
    }
    
    /// Clears all stubs.
    func reset() -> API.Config {
        StubURL.reset()
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
