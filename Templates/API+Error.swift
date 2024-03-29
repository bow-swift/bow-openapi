//  Copyright © 2019 The Bow Authors.

import Foundation
import {{ moduleName }}

public enum HTTPErrorTest {
    case malformedURL
    case parsingError
    case badRequest
    case forbidden
    case notFound
    case serverError
    case serviceUnavailable
    case unknown
    case other(error: Error? = nil)
}

extension HTTPErrorTest {
    func apiError(withData apiError: API.HTTPError) -> API.HTTPError {
        let dataError = apiError.dataError
        
        switch self {
        case .malformedURL: return .malformedURL(response: dataError!.response, data: dataError!.data)
        case .parsingError: return .parsingError(response: dataError!.response, data: dataError!.data)
        case .badRequest: return .badRequest(response: dataError!.response, data: dataError!.data)
        case .forbidden: return .forbidden(response: dataError!.response, data: dataError!.data)
        case .notFound: return .notFound(response: dataError!.response, data: dataError!.data)
        case .serverError: return .serverError(response: dataError!.response, data: dataError!.data)
        case .serviceUnavailable: return .serviceUnavailable(response: dataError!.response, data: dataError!.data)
        case .unknown: return .unknown(response: dataError!.response, data: dataError!.data)
        case .other(let error): return .other(error: error ?? apiError.error)
        }
    }
}
