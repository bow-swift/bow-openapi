//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import Swiftline

public class SwaggerClientGenerator: ClientGenerator {
    
    public init() { }
    
    public func generate(moduleName: String, scheme: URL, output: OutputURL, template: URL, log: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        let apiFolder = output.sources.appendingPathComponent("APIs")
        let apiFile = output.sources.appendingPathComponent("APIs.swift")
        
        return binding(
              |<-self.swaggerGenerator(scheme: scheme, output: output.sources, template: template, log: log),
              |<-self.reorganizeFiles(moduleName: moduleName, in: output, fromTemplate: template),
              |<-self.fixSignatureParameters(filesAt: apiFolder),
              |<-self.renderHelpersForHeaders(filesAt: apiFolder, inFile: apiFile),
              |<-self.removeHeadersDefinition(filesAt: apiFolder),
        yield: ())^
    }
    
    internal func swaggerGenerator(scheme: URL, output: URL, template: URL, log: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        func runSwagger() -> IO<APIClientError, ()> {
            IO.invoke {
                let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(scheme.path)", "--output", "\(output.path)", "--template-dir", "\(template.path)"]) { settings in
                    settings.execution = .log(file: log.path)
                }
                
                let hasError = result.exitStatus != 0 || result.stdout.contains("ERROR")
                if hasError { throw APIClientError(operation: "swaggerGenerator(scheme:output:template:logPath:)", error: GeneratorError.generator) }
            }
        }
        
        return EnvIO { _ in runSwagger() }
    }
    
    internal func reorganizeFiles(moduleName: String, in output: OutputURL, fromTemplate template: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            let swaggerFolder = output.sources.appendingPathComponent("SwaggerClient").appendingPathComponent("Classes").appendingPathComponent("Swaggers")
            let apiHelper = output.sources.appendingPathComponent("APIHelper.swift")
            
            return binding(
                |<-fileSystem.moveFiles(in: swaggerFolder, to: output.sources),
                |<-fileSystem.remove(from: output.sources, files: "Cartfile", "AlamofireImplementations.swift", "Models.swift", "git_push.sh", "SwaggerClient.podspec", "SwaggerClient", ".swagger-codegen", ".swagger-codegen-ignore", "JSONEncodableEncoding.swift", "JSONEncodingHelper.swift"),
                |<-fileSystem.rename("APIConfiguration.swift", itemAt: apiHelper),
                |<-self.copyTestFiles(moduleName: moduleName, template: template, output: output.tests).provide(fileSystem),
            yield: ())^.mapLeft(FileSystemError.toAPIClientError)
        }
    }
    
    internal func fixSignatureParameters(filesAt folder: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        func fixSignatureParameters(toFiles files: [URL]) -> EnvIO<FileSystem, FileSystemError, ()> {
            files.traverse(fixSignatureParameters(atFile:)).void()^
        }
        
        func fixSignatureParameters(atFile file: URL) -> EnvIO<FileSystem, FileSystemError, ()> {
            EnvIO { fileSystem in
                let content = IO<FileSystemError, String>.var()
                let fixedContent = IO<FileSystemError, String>.var()
                
                return binding(
                     content <- fileSystem.readFile(at: file),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "(, ", with: "(")
                                                   .replacingOccurrences(of: "(,", with: "(")),
                             |<-fileSystem.write(content: fixedContent.get, toFile: file),
                yield: ())
            }
        }
        
        return EnvIO { fileSystem in
            let items = IO<FileSystemError, [URL]>.var()
            
            return binding(
                items <- fileSystem.items(at: folder),
                      |<-fixSignatureParameters(toFiles: items.get).provide(fileSystem),
            yield: ())^.mapLeft(FileSystemError.toAPIClientError)
        }
    }
    
    private var regexHeaders: String { "(?s)(/\\* API.CONFIG.HEADERS.*\n).*(\\*/)" }
    
    internal func renderHelpersForHeaders(filesAt folder: URL, inFile: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        typealias HeaderValue = (type: String, header: String)
        
        func headerInformation(content: String) -> IO<FileSystemError, [String: HeaderValue]> {
            guard let plainHeaders = content.substring(pattern: regexHeaders)?.output.components(separatedBy: "\n") else {
                return IO.raiseError(FileSystemError.read(file: "::headerInformation"))^
            }
            
            let headers = plainHeaders.compactMap { string -> [String: HeaderValue]? in
                let components = string.components(separatedBy: ":")
                guard components.count == 3 else { return nil }
                return [components[0].trimmingWhitespaces: (components[1].trimmingWhitespaces, components[2].trimmingWhitespaces)]
            }
            
            return IO.pure(headers.combineAll())^
        }
        
        func renderHelpers(headers: [String: HeaderValue]) -> String {
            guard headers.count > 0 else { return "" }
            
            let methods = headers.map { (arg) -> String in
                let (key, (type, header)) = arg
                return """
                       
                           public func appendingHeader(\(key): \(type)) -> API.Config {
                               self.copy(headers: self.headers.combine(["\(header)": \(key)]))
                           }
                       """
            }
            
            return """
                   extension API.Config {
                   \(methods.reduce("", +))
                   }
                   """
        }
        
        return EnvIO { fileSystem in
            let items = IO<FileSystemError, [URL]>.var()
            let contents = IO<FileSystemError, [String]>.var()
            let headers = IO<FileSystemError, [[String: HeaderValue]]>.var()
            let flattenHeaders = IO<FileSystemError, [String: HeaderValue]>.var()
            let helpers = IO<FileSystemError, String>.var()
            let file = IO<FileSystemError, String>.var()
            
            return binding(
                         items <- fileSystem.items(at: folder),
                      contents <- items.get.traverse(fileSystem.readFile(at:)),
                       headers <- contents.get.traverse(headerInformation),
                flattenHeaders <- IO.pure(headers.get.combineAll()),
                       helpers <- IO.pure(renderHelpers(headers: flattenHeaders.get)),
                          file <- fileSystem.readFile(at: inFile),
                               |<-fileSystem.write(content: "\(file.get)\n\n\(helpers.get)", toFile: inFile),
            yield: ())^.mapLeft(FileSystemError.toAPIClientError)
        }
    }
    
    internal func removeHeadersDefinition(filesAt folder: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        func removeHeadersDefinition(atFile file: URL) -> EnvIO<FileSystem, FileSystemError, ()> {
            EnvIO { fileSystem in
                let content = IO<FileSystemError, String>.var()
                let headers = IO<FileSystemError, String>.var()
                let contentWithoutHeaders = IO<FileSystemError, String>.var()
                
                return binding(
                                  content <- fileSystem.readFile(at: file),
                                  headers <- IO.pure(content.get.substring(pattern: self.regexHeaders)?.output ?? ""),
                    contentWithoutHeaders <- IO.pure(content.get.clean(headers.get)),
                                          |<-fileSystem.write(content: contentWithoutHeaders.get, toFile: file),
                yield: ())^
            }
        }
        
        return EnvIO { fileSystem in
            let items = IO<FileSystemError, [URL]>.var()
            
            return binding(
                items <- fileSystem.items(at: folder),
                      |<-items.get.traverse(removeHeadersDefinition(atFile:))^.provide(fileSystem),
            yield: ())^.mapLeft(FileSystemError.toAPIClientError)
        }
    }
    
    internal func copyTestFiles(moduleName: String, template: URL, output: URL) -> EnvIO<FileSystem, FileSystemError, ()> {
        let files = ["API+XCTest.swift", "API+Error.swift", "APIConfigTesting.swift", "StubURL.swift"]
        
        return EnvIO { fileSystem in
            binding(
                |<-fileSystem.copy(items: files, from: template, to: output),
                |<-files.traverse { filename in self.fixTestFile(moduleName: moduleName, filename: filename, output: output).provide(fileSystem) },
            yield: ())^
        }^
    }
    
    internal func fixTestFile(moduleName: String, filename: String, output: URL) -> EnvIO<FileSystem, FileSystemError, ()> {
        let content = IO<FileSystemError, String>.var()
        let fixedContent = IO<FileSystemError, String>.var()
        let file = output.appendingPathComponent(filename)
        
        return EnvIO { fileSystem in
            binding(
                     content <- fileSystem.readFile(at: file),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: moduleName)),
                             |<-fileSystem.write(content: fixedContent.get, toFile: file),
            yield: ())
        }
    }
}
