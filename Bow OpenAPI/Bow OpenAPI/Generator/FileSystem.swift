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
}

class MacFileSystem: FileSystem {
    func createDirectory(atPath path: String) -> IO<FileSystemError, ()> {
        FileManager.default.createDirectoryIO(atPath: path, withIntermediateDirectories: false).mapLeft { _ in .create(item: path) }
    }
    
    func copy(itemPath atPath: String, toPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.copyItemIO(atPath: atPath, toPath: toPath).mapLeft { _ in .copy(from: atPath, to: toPath) }
    }
    
    func remove(itemPath: String) -> IO<FileSystemError, ()> {
        FileManager.default.removeItemIO(atPath: itemPath).mapLeft { _ in .remove(item: itemPath) }
    }
    
    func move(from input: String, to output: String) -> IO<FileSystemError, ()> {
        let items = IO<FileSystemError, [String]>.var()
        
        return binding(
            items <- self.items(atPath: input),
                  |<-self.copy(items: items.get, from: input, to: output),
            yield: ()
        )^.mapLeft { _ in .move(from: input, to: output) }
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
