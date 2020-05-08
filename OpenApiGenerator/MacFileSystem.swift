//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public class MacFileSystem: FileSystem {
    let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func createDirectory(atPath path: String, withIntermediateDirectories: Bool) -> IO<FileSystemError, ()> {
        fileManager.createDirectoryIO(atPath: path, withIntermediateDirectories: withIntermediateDirectories)
            .mapError { _ in .create(item: path) }
    }
    
    public func copy(itemPath atPath: String, toPath: String) -> IO<FileSystemError, ()> {
        fileManager.copyItemIO(atPath: atPath, toPath: toPath)
            .mapError { _ in .copy(from: atPath, to: toPath) }
    }
    
    public func remove(itemPath: String) -> IO<FileSystemError, ()> {
        fileManager.removeItemIO(atPath: itemPath)
            .mapError { _ in .remove(item: itemPath) }
    }
    
    public func items(atPath path: String) -> IO<FileSystemError, [String]> {
        fileManager.contentsOfDirectoryIO(atPath: path)
            .mapError { _ in .get(from: path) }
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
    
    public func exist(item: URL) -> Bool {
        fileManager.fileExists(atPath: item.path)
    }
}
