//  Copyright © 2019 The Bow Authors.

import Foundation

/// API Client <Error>
struct APIClientError: Error {
    let operation: String
    let error: Error & CustomStringConvertible
    
}

extension APIClientError: CustomStringConvertible {
    var description: String {
        return "operation: \(operation)\nerror: \(error)"
    }
}


/// API Client <step information>
enum APIClientStepError: Error {
    case templateNotFound
    case structure
    case generator
}

extension APIClientStepError: CustomStringConvertible {
    var description: String {
        switch self {
        case .templateNotFound:
            return "templates for generating Bow client have not been found"
        case .structure:
            return "could not create project structure"
        case .generator:
            return "command 'swagger-codegen' failed"
        }
    }
}
