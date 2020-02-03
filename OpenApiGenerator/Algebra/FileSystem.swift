//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public protocol FileSystem {
    func createDirectory(at folder: URL, withIntermediates: Bool) -> IO<FileSystemError, ()>
    func copy(item: URL, to output: URL) -> IO<FileSystemError, ()>
    func remove(item: URL) -> IO<FileSystemError, ()>
    func items(at folder: URL) -> IO<FileSystemError, [URL]>
    func readFile(at file: URL) -> IO<FileSystemError, String>
    func write(content: String, toFile file: URL) -> IO<FileSystemError, ()>
}

public extension FileSystem {
    func copy(item: String, from input: URL, to output: URL) -> IO<FileSystemError, ()> {
        copy(item: input.appendingPathComponent(item), to: output.appendingPathComponent(item))
    }
    
    func copy(items: [String], from input: URL, to output: URL) -> IO<FileSystemError, ()> {
        items.traverse { item in
            self.copy(item: item, from: input, to: output)
        }.void()^
    }
    
    func remove(from folder: URL, files: String...) -> IO<FileSystemError, ()> {
        files.traverse { file in self.remove(item: folder.appendingPathComponent(file)) }.void()^
    }
    
    func removeFiles(_ files: URL...) -> IO<FileSystemError, ()> {
        files.traverse(remove(item:)).void()^
    }
    
    func moveFile(from origin: URL, to destination: URL) -> IO<FileSystemError, Void> {
        copy(item: origin, to: destination)
            .followedBy(removeFiles(origin))^
            .mapLeft { _ in .move(from: origin.path, to: destination.path) }
    }
    
    func moveFiles(in input: URL, to output: URL) -> IO<FileSystemError, ()> {
        let items = IO<FileSystemError, [String]>.var()
        
        return binding(
            items <- self.items(at: input).map { files in files.map { file in file.lastPathComponent } },
                  |<-self.copy(items: items.get, from: input, to: output),
                  |<-self.remove(item: input),
            yield: ()
            )^.mapLeft { _ in .move(from: input.path, to: output.path) }
    }
    
    func rename(_ newName: String, itemAt: URL) -> IO<FileSystemError, ()> {
        moveFile(from: itemAt, to: itemAt.deletingLastPathComponent().appendingPathComponent(newName))
    }
}
