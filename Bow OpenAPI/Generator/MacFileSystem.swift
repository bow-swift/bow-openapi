//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

class MacFileSystem: FileSystem {
    
    func createDirectory(atPath path: String) -> IO<FileSystemError, ()> {
        FileManager.default.createDirectoryIO(atPath: path, withIntermediateDirectories: false)
            .mapLeft { _ in .create(item: path) }
    }
    
    func copy(itemPath atPath: String, toPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.copyItemIO(atPath: atPath, toPath: toPath)
            .mapLeft { _ in .copy(from: atPath, to: toPath) }
    }
    
    func remove(itemPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.removeItemIO(atPath: itemPath)
            .mapLeft { _ in .remove(item: itemPath) }
    }
    
    func items(atPath path: String) -> IO<FileSystemError, [String]> {
        FileManager.default.contentsOfDirectoryIO(atPath: path)
                           .mapLeft { _ in .get(from: path) }
                           .map { files in files.map({ file in "\(path)/\(file)"}) }^
    }
    
    func readFile(atPath path: String) -> IO<FileSystemError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: path)
            } catch {
                throw FileSystemError.read(file: path)
            }
        }
    }
    
    func write(content: String, toFile path: String) -> IO<FileSystemError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                throw FileSystemError.write(file: path)
            }
        }
    }
}
