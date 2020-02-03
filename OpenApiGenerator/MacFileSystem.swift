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
    
    public func copy(item: URL, to output: URL) -> IO<FileSystemError, ()> {
        FileManager.default.copyItemIO(at: item, to: output)
                           .mapLeft { _ in .copy(from: item.path, to: output.path) }
    }
    
    public func remove(item: URL) -> IO<FileSystemError, ()> {
        FileManager.default.removeItemIO(at: item)
                           .mapLeft { _ in .remove(item: item.path) }
    }
    
    public func items(at folder: URL) -> IO<FileSystemError, [URL]> {
        FileManager.default.contentsOfDirectoryIO(at: folder, includingPropertiesForKeys: nil)
                           .mapLeft { _ in .get(from: folder.path) }^
    }
    
    public func readFile(at file: URL) -> IO<FileSystemError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: file.path)
            } catch {
                throw FileSystemError.read(file: file.path)
            }
        }
    }
    
    public func write(content: String, toFile file: URL) -> IO<FileSystemError, ()> {
        IO.invoke {
            do {
                try content.write(to: file, atomically: true, encoding: .utf8)
            } catch {
                throw FileSystemError.write(file: file.path)
            }
        }
    }
}
