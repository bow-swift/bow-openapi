//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import OpenApiGenerator

class FileSystemMock: FileSystem {
    
    private let shouldFail: Bool
    private(set) var createDirectoryInvoked = false
    private(set) var itemsAtPathInvoked = false
    private(set) var readFileAtPathInvoked = false
    private(set) var writeContentInvoked = false
    private(set) var copyItemPathInvoked = false
    private(set) var removeItemPathInvoked = false
    
    init(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    
    func createDirectory(atPath: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.createDirectoryInvoked = true
            if self.shouldFail { throw FileSystemError.create(item: atPath) }
        }
    }
    
    func items(atPath path: String) -> IO<FileSystemError, [String]> {
        IO.invoke {
            self.itemsAtPathInvoked = true
            if self.shouldFail { throw FileSystemError.get(from: path) }
            else { return [""] }
        }
    }
    
    func readFile(atPath path: String) -> IO<FileSystemError, String> {
        IO.invoke {
            self.readFileAtPathInvoked = true
            if self.shouldFail { throw FileSystemError.read(file: path) }
            else { return "" }
        }
    }
    
    func write(content: String, toFile path: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.writeContentInvoked = true
            if self.shouldFail { throw FileSystemError.write(file: path) }
        }
    }
    
    func copy(itemPath: String, toPath: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.copyItemPathInvoked = true
            if self.shouldFail { throw FileSystemError.copy(from: itemPath, to: toPath) }
        }
    }
    
    func remove(itemPath: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.removeItemPathInvoked = true
            if self.shouldFail { throw FileSystemError.remove(item: itemPath) }
        }
    }
    
}
