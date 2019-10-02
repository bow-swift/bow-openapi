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
