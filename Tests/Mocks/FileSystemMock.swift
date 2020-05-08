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
    
    
    func createDirectory(at: URL, withIntermediateDirectories: Bool) -> IO<FileSystemError, Void> {
        IO.invoke {
            self.createDirectoryInvoked = true
            if self.shouldFail { throw FileSystemError.create(item: at) }
        }
    }
    
    func items(at: URL) -> IO<FileSystemError, [URL]> {
        IO.invoke {
            self.itemsAtPathInvoked = true
            if self.shouldFail { throw FileSystemError.get(from: at) }
            else { return [URL(fileURLWithPath: "")] }
        }
    }
    
    func readFile(at: URL) -> IO<FileSystemError, String> {
        IO.invoke {
            self.readFileAtPathInvoked = true
            if self.shouldFail { throw FileSystemError.read(file: at) }
            else { return "" }
        }
    }
    
    func write(content: String, toFile: URL) -> IO<FileSystemError, Void> {
        IO.invoke {
            self.writeContentInvoked = true
            if self.shouldFail { throw FileSystemError.write(file: toFile) }
        }
    }
    
    func copy(item: URL, to: URL) -> IO<FileSystemError, Void> {
        IO.invoke {
            self.copyItemPathInvoked = true
            if self.shouldFail { throw FileSystemError.copy(from: item, to: to) }
        }
    }
    
    func remove(item: URL) -> IO<FileSystemError, Void> {
        IO.invoke {
            self.removeItemPathInvoked = true
            if self.shouldFail { throw FileSystemError.remove(item: item) }
        }
    }
    
    func exist(item: URL) -> Bool { true }
}
