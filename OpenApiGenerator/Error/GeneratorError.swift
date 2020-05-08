//  Copyright © 2019 The Bow Authors.

import Foundation

/// General information about the errors in the generator
public enum GeneratorError: Error {
    case invalidParameters
    case templateNotFound
    case structure
    case existOutput(directory: URL)
    case generator
}

extension GeneratorError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidParameters:
            return "received invalid parameters"
        case .templateNotFound:
            return "templates for generating Bow client have not been found"
        case .structure:
            return "could not create project structure"
        case .existOutput(let directory):
            return "output directory '\(directory.path)' already exists"
        case .generator:
            return "command 'swagger-codegen' failed"
        }
    }
}
