//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public class MacFileSystem: FileSystem {
    let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func createDirectory(at directory: URL, withIntermediateDirectories: Bool) -> IO<FileSystemError, Void> {
        fileManager.createDirectoryIO(atPath: directory.path, withIntermediateDirectories: withIntermediateDirectories)
            .mapError { _ in .create(item: directory) }
    }
    
    public func copy(item: URL, to: URL) -> IO<FileSystemError, Void> {
        fileManager.copyItemIO(atPath: item.path, toPath: to.path)
            .mapError { _ in .copy(from: item, to: to) }
    }
    
    public func remove(item: URL) -> IO<FileSystemError, Void> {
        fileManager.removeItemIO(atPath: item.path)
            .mapError { _ in .remove(item: item) }
    }
    
    public func items(at: URL) -> IO<FileSystemError, [URL]> {
        fileManager.contentsOfDirectoryIO(atPath: at.path)
            .mapError { _ in .get(from: at) }
            .map { files in files.map({ file in at.appendingPathComponent(file) }) }^
    }
    
    public func readFile(at: URL) -> IO<FileSystemError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: at.path)
            } catch {
                throw FileSystemError.read(file: at)
            }
        }
    }
    
    public func write(content: String, toFile item: URL) -> IO<FileSystemError, Void> {
        IO.invoke {
            do {
                try content.write(toFile: item.path, atomically: true, encoding: .utf8)
            } catch {
                throw FileSystemError.write(file: item)
            }
        }
    }
    
    public func exist(item: URL) -> Bool {
        fileManager.fileExists(atPath: item.path)
    }
}
