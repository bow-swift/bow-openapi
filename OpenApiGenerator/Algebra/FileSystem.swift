//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public protocol FileSystem {
    func createDirectory(at: URL, withIntermediateDirectories: Bool) -> IO<FileSystemError, Void>
    func copy(item: URL, to: URL) -> IO<FileSystemError, Void>
    func remove(item: URL) -> IO<FileSystemError, Void>
    func items(at: URL) -> IO<FileSystemError, [URL]>
    func readFile(at: URL) -> IO<FileSystemError, String>
    func write(content: String, toFile: URL) -> IO<FileSystemError, Void>
    func exist(item: URL) -> Bool
}

public extension FileSystem {
    func createDirectory(at directory: URL) -> IO<FileSystemError, Void> {
        createDirectory(at: directory, withIntermediateDirectories: false)
    }
    
    func copy(item: String, from input: URL, to output: URL) -> IO<FileSystemError, Void> {
        copy(item: input.appendingPathComponent(item), to: output.appendingPathComponent(item))
    }
    
    func copy(items: [String], from input: URL, to output: URL) -> IO<FileSystemError, Void> {
        items.traverse { (item: String) in
            self.copy(item: item.filename, from: input, to: output)
        }.void()^
    }
    
    func remove(in directory: URL, files: [String]) -> IO<FileSystemError, Void> {
        files.traverse { file in self.remove(item: directory.appendingPathComponent(file)) }.void()^
    }
    
    func removeDirectory(_ directory: URL) -> IO<FileSystemError, Void> {
        let outputURL = URL(fileURLWithPath: directory.path, isDirectory: true)
        return remove(item: outputURL)
    }
    
    func removeFiles(_ files: [URL]) -> IO<FileSystemError, Void> {
        files.traverse(remove(item:)).void()^
    }
    
    func moveFile(from origin: URL, to destination: URL) -> IO<FileSystemError, Void> {
        copy(item: origin, to: destination)
            .followedBy(removeFiles([origin]))^
            .mapError { _ in .move(from: origin, to: destination) }
    }
    
    func moveFiles(in input: URL, to output: URL) -> IO<FileSystemError, Void> {
        let items = IO<FileSystemError, [URL]>.var()
        
        return binding(
            items <- self.items(at: input),
                  |<-self.copy(items: items.get.map(\.path), from: input, to: output),
                  |<-self.removeDirectory(input),
            yield: ()
        )^.mapError { _ in .move(from: input, to: output) }
    }
    
    func rename(with newName: String, item: URL) -> IO<FileSystemError, Void> {
        let newItem = item.deletingLastPathComponent().appendingPathComponent(newName)
        return moveFile(from: item, to: newItem)
    }
}
