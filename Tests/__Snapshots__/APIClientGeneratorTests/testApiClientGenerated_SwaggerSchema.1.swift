//
//  DefaultAPI.swift
//
//  Generated by bow-openapi
//  Copyright © 2020 Bow Authors. All rights reserved.
//

import Foundation
import Bow
import BowEffects

/// `DefaultAPI` provider
public extension API {
    static var `default`: DefaultAPI {
        return DefaultAPIClient()
    }
}


/// Protocol to define networking operations in `default`
public protocol DefaultAPI {
    func _testSchema() -> EnvIO<API.Config, API.HTTPError, NoResponse>
}

extension DefaultAPI {

    /**

     - Returns: An `EnvIO` to perform IO operations that produce errors of type `HTTPError` and values of type `Void`, having access to an immutable environment of type `API.Config`. It can be seen as a Kleisli function `(API.Config) -> IO<API.HTTPError, NoResponse>`.
     */
    public func testSchema() -> EnvIO<API.Config, API.HTTPError, NoResponse> {
        _testSchema()
    }
}


/// An HTTP client to perform networking operations related to `default`
class DefaultAPIClient: DefaultAPI {

    func _testSchema() -> EnvIO<API.Config, API.HTTPError, NoResponse> {
        return EnvIO { apiConfig in
            // build request path
            let resourcePath = "/pet"
            let path = apiConfig.basePath + resourcePath
            
            // make parameters
            let parameters: [String: Any]? = nil
            let components = URLComponents(string: path)
            
            // request configuration
            guard let url = components?.url ?? URL(string: path) else {
                let data = "DefaultAPI.testSchema.URL".data(using: .utf8)!
                return IO.raiseError(.malformedURL(response: URLResponse(), data: data))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addHeaders(apiConfig.headers)
            request.setParameters(parameters)

            // launch request
            return API.send(request: request, session: apiConfig.session, decoder: apiConfig.decoder)
        }
    }
}

