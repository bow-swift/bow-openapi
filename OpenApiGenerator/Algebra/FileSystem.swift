//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public protocol FileSystem {
    func createDirectory(atPath path: String, withIntermediateDirectories: Bool) -> IO<FileSystemError, ()>
    func copy(itemPath: String, toPath: String) -> IO<FileSystemError, ()>
    func remove(itemPath: String) -> IO<FileSystemError, ()>
    func items(atPath path: String) -> IO<FileSystemError, [String]>
    func readFile(atPath path: String) -> IO<FileSystemError, String>
    func write(content: String, toFile path: String) -> IO<FileSystemError, ()>
    func exist(item: URL) -> Bool
}

public extension FileSystem {
    func createDirectory(atPath path: String) -> IO<FileSystemError, ()> {
        createDirectory(atPath: path, withIntermediateDirectories: false)
    }
    
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
    
    func removeDirectory(_ output: String) -> IO<FileSystemError, ()> {
        let outputURL = URL(fileURLWithPath: output, isDirectory: true)
        return remove(itemPath: outputURL.path)
    }
    
    func removeFiles(_ files: String...) -> IO<FileSystemError, ()> {
        files.traverse(remove(itemPath:)).void()^
    }
    
    func moveFile(from origin: String, to destination: String) -> IO<FileSystemError, Void> {
        copy(itemPath: origin, toPath: destination)
            .followedBy(removeFiles(origin))^
            .mapError { _ in .move(from: origin, to: destination) }
    }
    
    func moveFiles(in input: String, to output: String) -> IO<FileSystemError, ()> {
        let items = IO<FileSystemError, [String]>.var()
        
        return binding(
            items <- self.items(atPath: input),
                  |<-self.copy(items: items.get, from: input, to: output),
                  |<-self.removeDirectory(input),
            yield: ()
        )^.mapError { _ in .move(from: input, to: output) }
    }
    
    func rename(_ newName: String, itemAt: String) -> IO<FileSystemError, ()> {
        moveFile(from: itemAt, to: "\(itemAt.parentPath)/\(newName)")
    }
}
