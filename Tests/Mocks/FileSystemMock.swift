//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

@testable import OpenApiGenerator


class FileSystemMock: FileSystem {
    private let shouldFail: Bool
    private(set) var createDirectoryInvoked = false
    private(set) var itemsAtPathInvoked = false
    private(set) var readFileAtPathInvoked = false
    private(set) var writeContentInvoked = false
    private(set) var copyItemPathInvoked = false
    private(set) var removeItemPathInvoked = false
    private(set) var existItemInvoked = false
    
    init(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    
    func createDirectory(at folder: URL, withIntermediates: Bool) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.createDirectoryInvoked = true
            if self.shouldFail { throw FileSystemError.create(item: folder.path) }
        }
    }
    
    func items(at folder: URL) -> IO<FileSystemError, [URL]> {
        IO.invoke {
            self.itemsAtPathInvoked = true
            if self.shouldFail { throw FileSystemError.get(from: folder.path) }
            else { return [] }
        }
    }
    
    func readFile(at file: URL) -> IO<FileSystemError, String> {
        IO.invoke {
            self.readFileAtPathInvoked = true
            if self.shouldFail { throw FileSystemError.read(file: file.path) }
            else { return "" }
        }
    }
    
    func write(content: String, toFile file: URL) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.writeContentInvoked = true
            if self.shouldFail { throw FileSystemError.write(file: file.path) }
        }
    }
    
    func copy(item: URL, to output: URL) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.copyItemPathInvoked = true
            if self.shouldFail { throw FileSystemError.copy(from: item.path, to: output.path) }
        }
    }
    
    func remove(item: URL) -> IO<FileSystemError, ()> {
        IO.invoke {
            self.removeItemPathInvoked = true
            if self.shouldFail { throw FileSystemError.remove(item: item.path) }
        }
    }
    
    func exist(item: URL) -> Bool {
        existItemInvoked = true
        return shouldFail ? true : false
    }
}
