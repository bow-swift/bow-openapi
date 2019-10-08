//  Copyright © 2019 The Bow Authors.

import Foundation

/// API Client <Error>
public struct APIClientError: Error {
    let operation: String
    let error: Error & CustomStringConvertible
}

extension APIClientError: CustomStringConvertible {
    public var description: String {
        return "operation: \(operation)\nerror: \(error)"
    }
}
