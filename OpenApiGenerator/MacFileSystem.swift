//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public class MacFileSystem: FileSystem {
    
    public init() { }
    
    public func createDirectory(at folder: URL, withIntermediates: Bool = false) -> IO<FileSystemError, ()> {
        FileManager.default.createDirectoryIO(atPath: folder.path, withIntermediateDirectories: withIntermediates)
                           .mapLeft { _ in .create(item: folder.path) }
    }
    
    public func copy(itemPath atPath: String, toPath: String) -> IO<FileSystemError, ()> {
        print("File: \(atPath)\nTo:\(toPath)")
        return FileManager.default.copyItemIO(atPath: atPath, toPath: toPath)
            .mapLeft { _ in .copy(from: atPath, to: toPath) }
    }
    
    public func remove(itemPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.removeItemIO(atPath: itemPath)
            .mapLeft { _ in .remove(item: itemPath) }
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
