//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

protocol FileSystem {
    func createDirectory(atPath: String) -> IO<FileSystemError, ()>
    func copy(itemPath: String, toPath: String) -> IO<FileSystemError, ()>
    func remove(itemPath: String) -> IO<FileSystemError, ()>
    func move(from input: String, to output: String) -> IO<FileSystemError, ()>
    func items(atPath path: String) -> IO<FileSystemError, [String]>
    func readFile(atPath path: String) -> IO<FileSystemError, String>
    func write(content: String, toFile path: String) -> IO<FileSystemError, ()>
    func rename(_ name: String, itemAt: String) -> IO<FileSystemError, ()>
}

extension FileSystem {
    func copy(item: String, from input: String, to output: String) -> IO<FileSystemError, ()> {
        copy(itemPath: "\(input)/\(item)", toPath: "\(output)/\(item)")
    }
    
    func copy(items: [String], from input: String, to output: String) -> IO<FileSystemError, ()> {
        items.traverse { (itemPath: String) in
            self.copy(item: itemPath.filename, from: input, to: output)
        }.void()^
    }
    
    func remove(from folder: String, files: String...) -> IO<FileSystemError, ()> {
        files.traverse { file in self.remove(itemPath: "\(folder)/\(file)") }.void()^
    }
    
    func removeDirectory(output: String) -> IO<FileSystemError, ()> {
        let outputURL = URL(fileURLWithPath: output, isDirectory: true)
        return remove(itemPath: outputURL.path)
    }
    
    func removeFiles(_ files: String...) -> IO<FileSystemError, ()> {
        files.traverse(remove(itemPath:)).void()^
    }
    
    func rename(_ name: String, itemAt: String) -> IO<FileSystemError, ()> {
        let copyItem = copy(itemPath: itemAt, toPath: "\(itemAt.parentPath)/\(name).\(itemAt.extension)")
        let removeCopiedItem = removeFiles(itemAt)
        
        return copyItem.followedBy(removeCopiedItem)^
    }
}
