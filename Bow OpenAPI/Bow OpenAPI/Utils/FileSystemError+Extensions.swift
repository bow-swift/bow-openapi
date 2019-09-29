//  Copyright © 2019 The Bow Authors.

import Foundation

extension FileSystemError {
    static func toAPIClientError(_ error: FileSystemError) -> APIClientError {
        APIClientError(operation: "FileSystem", error: error)
    }
}
