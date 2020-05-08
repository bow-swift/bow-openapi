//  Copyright © 2019 The Bow Authors.

import Foundation

public enum FileSystemError: Error {
    case create(item: URL)
    case copy(from: URL, to: URL)
    case remove(item: URL)
    case move(from: URL, to: URL)
    case get(from: URL)
    case read(file: URL)
    case invalidContent(info: String)
    case write(file: URL)
}

extension FileSystemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .create(let item):
            return "cannot create item '\(item.path)'"
        case .copy(let from, let to):
            return "cannot copy item at '\(from.path)' to '\(to.path)'"
        case .remove(let item):
            return "cannot remove item at '\(item.path)'"
        case .move(let from, let to):
            return "cannot move item from '\(from.path)' to '\(to.path)'"
        case .get(let from):
            return "cannot get items from '\(from.path)'"
        case .read(let file):
            return "cannot read content of file '\(file.path)'"
        case .invalidContent(let info):
            return "invalid content file \(info)"
        case .write(let file):
            return "cannot write in file '\(file.path)'"
        }
    }
}


/// MARK: Helper to get APIClientError given a FileSystemError
extension FileSystemError {
    static func toAPIClientError(_ error: FileSystemError) -> APIClientError {
        APIClientError(operation: "FileSystem", error: error)
    }
}
