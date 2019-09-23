//  Copyright © 2019 The Bow Authors.

import Foundation

enum APIClientError: Error {
    case structure
    case generator
    case templateNotFound
    case removeOperation(file: String)
    case moveOperation(input: String, output: String)
}

extension APIClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case .structure:
            return "could not create project structure"
        case .generator:
            return "command 'swagger-codegen' failed"
        case .templateNotFound:
            return "templates for generating Bow client have not been found"
        case let .removeOperation(file):
            return "can not remove the file '\(file)'"
        case let .moveOperation(input, output):
            return "can not move items in '\(input)' to '\(output)'"
        }
    }
}
