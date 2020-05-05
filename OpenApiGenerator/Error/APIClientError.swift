//  Copyright © 2019 The Bow Authors.

import Foundation

/// API Client <Error>
public struct APIClientError: Error {
    public let operation: String
    public let error: Error & CustomStringConvertible
    
    public init(operation: String, error: Error & CustomStringConvertible) {
        self.operation = operation
        self.error = error
    }
}

extension APIClientError: CustomStringConvertible {
    public var description: String {
        return "operation: \(operation)\nerror: \(error)"
    }
}
