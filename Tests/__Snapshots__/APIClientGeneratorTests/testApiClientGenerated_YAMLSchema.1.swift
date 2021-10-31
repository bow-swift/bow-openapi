//
//  DefaultAPI.swift
//
//  Generated by bow-openapi
//  Copyright © 2021 Bow Authors. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
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
    func _testSchemaFormat() -> EnvIO<API.Config, API.HTTPError, NoResponse>
}

extension DefaultAPI {

    /**
     List all pets

     - Returns: An `EnvIO` to perform IO operations that produce errors of type `HTTPError` and values of type `Void`, having access to an immutable environment of type `API.Config`.
     */
    public func testSchemaFormat() -> EnvIO<API.Config, API.HTTPError, NoResponse> {
        _testSchemaFormat()
    }
}


/// An HTTP client to perform networking operations related to `default`
class DefaultAPIClient: DefaultAPI {

    func _testSchemaFormat() -> EnvIO<API.Config, API.HTTPError, NoResponse> {
        return EnvIO { apiConfig in
            // build request path
            let resourcePath = "/pets"
            let path = apiConfig.basePath + resourcePath
            
            // make parameters
            
            let components = URLComponents(string: path)
            
            // request configuration
            guard let url = components?.url ?? URL(string: path) else {
                let data = "DefaultAPI.testSchemaFormat.URL".data(using: .utf8)!
                return IO.raiseError(.malformedURL(response: URLResponse.empty, data: data))
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addHeaders(apiConfig.headers)
            
            // launch request
            return API.send(request: request, session: apiConfig.session, decoder: apiConfig.decoder)
        }
    }
}

