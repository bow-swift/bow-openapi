//  Copyright © 2019 The Bow Authors.

import Foundation

/// General information about the errors in the generator
enum GeneratorError: Error {
    case templateNotFound
    case structure
    case generator
}

extension GeneratorError: CustomStringConvertible {
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
