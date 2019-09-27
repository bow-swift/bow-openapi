//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

protocol FileSystem {
    func createDirectory(output: String) -> IO<APIClientError, ()>
    func copy(item: String, from input: String, to output: String) -> IO<APIClientError, ()>
    func move(from input: String, to output: String) -> IO<APIClientError, ()>
    func files(atPath path: String) -> IO<APIClientError, [String]>
    func removeFiles(_ files: String...) -> IO<APIClientError, ()>
    func readFile(atPath path: String) -> IO<APIClientError, String>
    func write(content: String, atPath path: String) -> IO<APIClientError, ()>
    func removeDirectory(output: String) -> IO<APIClientError, ()>
}

extension FileSystem {
    func copy(items: [String], from input: String, to output: String) -> IO<APIClientError, ()> {
        items.traverse { (itemPath: String) in
            self.copy(item: itemPath.filename, from: input, to: output)
        }.void()^
    }
    
    func remove(from folder: String, files: String...) -> IO<APIClientError, ()> {
        files.traverse { file in self.removeFiles("\(folder)/\(file)") }.void()^
    }
}

class MacFileSystem: FileSystem {
    func createDirectory(output: String) -> IO<APIClientError, ()> {
        FileManager.default.createDirectoryIO(atPath: output, withIntermediateDirectories: false).mapLeft { _ in .structure }
    }
    
    func copy(item: String, from input: String, to output: String) -> IO<APIClientError, ()> {
        FileManager.default.copyItemIO(atPath: "\(input)/\(item)", toPath: "\(output)/\(item)")
                           .mapLeft { _ in .moveOperation(input: input, output: output) }
    }
    
    func move(from input: String, to output: String) -> IO<APIClientError, ()> {
        let items = IO<APIClientError, [String]>.var()
        
        return binding(
            items <- self.files(atPath: input),
                  |<-self.copy(items: items.get, from: input, to: output),
            yield: ()
        )^
    }
    
    func files(atPath path: String) -> IO<APIClientError, [String]> {
        FileManager.default.contentsOfDirectoryIO(atPath: path)
                           .mapLeft {_ in .structure }
                           .map { files in files.map({ file in "\(path)/\(file)"}) }^
    }
    
    func removeFiles(_ files: String...) -> IO<APIClientError, ()> {
        files.traverse { file in
            FileManager.default.removeItemIO(atPath: file)
                .mapLeft { _ in APIClientError.removeOperation(file: file) }
        }.void()^
    }
    
    func readFile(atPath path: String) -> IO<APIClientError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: path)
            } catch {
                throw APIClientError.read(file: path)
            }
        }
    }
    
    func write(content: String, atPath path: String) -> IO<APIClientError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                throw APIClientError.write(file: path)
            }
        }
    }
    
    func removeDirectory(output: String) -> IO<APIClientError, ()> {
        IO.invoke {
            let outputURL = URL(fileURLWithPath: output, isDirectory: true)
            let _ = try? FileManager.default.removeItem(at: outputURL)
        }
    }
}
