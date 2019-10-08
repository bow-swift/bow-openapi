//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public class MacFileSystem: FileSystem {
    
    public init() { }
    
    public func createDirectory(atPath path: String) -> IO<FileSystemError, ()> {
        FileManager.default.createDirectoryIO(atPath: path, withIntermediateDirectories: false)
            .mapLeft { _ in .create(item: path) }
    }
    
    public func copy(itemPath atPath: String, toPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.copyItemIO(atPath: atPath, toPath: toPath)
            .mapLeft { _ in .copy(from: atPath, to: toPath) }
    }
    
    public func remove(itemPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.removeItemIO(atPath: itemPath)
            .mapLeft { _ in .remove(item: itemPath) }
    }
    
    public func move(from input: String, to output: String) -> IO<FileSystemError, ()> {
        let items = IO<FileSystemError, [String]>.var()
        
        return binding(
            items <- self.items(atPath: input),
                  |<-self.copy(items: items.get, from: input, to: output),
            yield: ()
        )^.mapLeft { _ in .move(from: input, to: output) }
    }
    
    public func items(atPath path: String) -> IO<FileSystemError, [String]> {
        FileManager.default.contentsOfDirectoryIO(atPath: path)
                           .mapLeft { _ in .get(from: path) }
                           .map { files in files.map({ file in "\(path)/\(file)"}) }^
    }
    
    public func readFile(atPath path: String) -> IO<FileSystemError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: path)
            } catch {
                throw FileSystemError.read(file: path)
            }
        }
    }
    
    public func write(content: String, toFile path: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                throw FileSystemError.write(file: path)
            }
        }
    }
}
