//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import Swiftline

public class SwaggerClientGenerator: ClientGenerator {
    
    public init() { }
    
    public func generate(moduleName: String, schemePath: String, outputPath: OutputPath, template: URL, logPath: String) -> EnvIO<FileSystem, APIClientError, ()> {
        return binding(
              |<-self.swaggerGenerator(scheme: schemePath, output: outputPath.sources, template: template, logPath: logPath),
              |<-self.reorganizeFiles(moduleName: moduleName, in: outputPath, fromTemplate: template),
              |<-self.fixSignatureParameters(filesAt: "\(outputPath.sources)/APIs"),
              |<-self.renderHelpersForHeaders(filesAt: "\(outputPath.sources)/APIs", inFile: "\(outputPath.sources)/APIs.swift"),
              |<-self.removeHeadersDefinition(filesAt: "\(outputPath.sources)/APIs"),
        yield: ())^
    }
    
    public func getTemplates() -> EnvIO<FileSystem, APIClientError, URL> {
        EnvIO.invoke { _ in
            let result = run("which", args: ["bow-openapi"])
            guard result.exitStatus == 0 && !result.stdout.contains("ERROR") else {
               throw APIClientError(operation: "getTemplates", error: GeneratorError.templateNotFound)
            }
            
            let binaryURL = URL(fileURLWithPath: result.stdout)
            return binaryURL.deletingLastPathComponent()
                .appendingPathComponent("bowopenapi")
                .appendingPathComponent("Templates")
        }
    }
    
    internal func swaggerGenerator(scheme: String, output: String, template: URL, logPath: String) -> EnvIO<FileSystem, APIClientError, ()> {
        func runSwagger() -> IO<APIClientError, ()> {
            IO.invoke {
                #if os(Linux)
                let result = run("java", args: ["-jar", "/usr/local/bin/swagger-codegen-cli.jar"] + ["generate", "--lang", "swift4", "--input-spec", "\(scheme)", "--output", "\(output)", "--template-dir", "\(template.path)"])
                #else
                let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(scheme)", "--output", "\(output)", "--template-dir", "\(template.path)"]) { settings in
                    settings.execution = .log(file: logPath)
                }
                #endif
                
                let hasError = result.exitStatus != 0 || result.stdout.contains("ERROR")
                if hasError { throw APIClientError(operation: "swaggerGenerator(scheme:output:template:logPath:)", error: GeneratorError.generator) }
            }
        }
        
        return EnvIO { _ in runSwagger() }
    }
    
    internal func reorganizeFiles(moduleName: String, in outputPath: OutputPath, fromTemplate template: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            binding(
                |<-fileSystem.moveFiles(in: "\(outputPath.sources)/SwaggerClient/Classes/Swaggers", to: outputPath.sources),
                |<-fileSystem.remove(from: outputPath.sources, files: "Cartfile", "AlamofireImplementations.swift", "Models.swift", "git_push.sh", "SwaggerClient.podspec", "SwaggerClient", ".swagger-codegen", ".swagger-codegen-ignore", "JSONEncodableEncoding.swift", "JSONEncodingHelper.swift"),
                |<-fileSystem.rename("APIConfiguration.swift", itemAt: "\(outputPath.sources)/APIHelper.swift"),
                |<-self.copyTestFiles(moduleName: moduleName, template: template, outputPath: outputPath.tests).provide(fileSystem),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    internal func fixSignatureParameters(filesAt path: String) -> EnvIO<FileSystem, APIClientError, ()> {
        func fixSignatureParameters(toFiles files: [String]) -> EnvIO<FileSystem, FileSystemError, ()> {
            files.traverse(fixSignatureParameters(atFile:)).void()^
        }
        
        func fixSignatureParameters(atFile path: String) -> EnvIO<FileSystem, FileSystemError, ()> {
            EnvIO { fileSystem in
                let content = IO<FileSystemError, String>.var()
                let fixedContent = IO<FileSystemError, String>.var()
                
                return binding(
                     content <- fileSystem.readFile(atPath: path),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "(, ", with: "(")
                                                   .replacingOccurrences(of: "(,", with: "(")),
                             |<-fileSystem.write(content: fixedContent.get, toFile: path),
                yield: ())
            }
        }
        
        return EnvIO { fileSystem in
            let items = IO<FileSystemError, [String]>.var()
            
            return binding(
                items <- fileSystem.items(atPath: path),
                      |<-fixSignatureParameters(toFiles: items.get).provide(fileSystem),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    private var regexHeaders: String { "(?s)(/\\* API.CONFIG.HEADERS.*\n).*(\\*/)" }
    
    internal func renderHelpersForHeaders(filesAt path: String, inFile output: String) -> EnvIO<FileSystem, APIClientError, ()> {
        typealias HeaderValue = (type: String, header: String)
        
        func headerInformation(content: String) -> IO<FileSystemError, [String: HeaderValue]> {
            guard let plainHeaders = content.substring(pattern: regexHeaders)?.ouput.components(separatedBy: "\n") else {
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
            let items = IO<FileSystemError, [String]>.var()
            let contents = IO<FileSystemError, [String]>.var()
            let headers = IO<FileSystemError, [[String: HeaderValue]]>.var()
            let flattenHeaders = IO<FileSystemError, [String: HeaderValue]>.var()
            let helpers = IO<FileSystemError, String>.var()
            let file = IO<FileSystemError, String>.var()
            
            return binding(
                         items <- fileSystem.items(atPath: path),
                      contents <- items.get.traverse(fileSystem.readFile(atPath:)),
                       headers <- contents.get.traverse(headerInformation),
                flattenHeaders <- IO.pure(headers.get.combineAll()),
                       helpers <- IO.pure(renderHelpers(headers: flattenHeaders.get)),
                          file <- fileSystem.readFile(atPath: output),
                               |<-fileSystem.write(content: "\(file.get)\n\n\(helpers.get)", toFile: output),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    internal func removeHeadersDefinition(filesAt path: String) -> EnvIO<FileSystem, APIClientError, ()> {
        func removeHeadersDefinition(atFile file: String) -> EnvIO<FileSystem, FileSystemError, ()> {
            EnvIO { fileSystem in
                let content = IO<FileSystemError, String>.var()
                let headers = IO<FileSystemError, String>.var()
                let contentWithoutHeaders = IO<FileSystemError, String>.var()
                
                return binding(
                                  content <- fileSystem.readFile(atPath: file),
                                  headers <- IO.pure(content.get.substring(pattern: self.regexHeaders)?.ouput ?? ""),
                    contentWithoutHeaders <- IO.pure(content.get.clean(headers.get)),
                                          |<-fileSystem.write(content: contentWithoutHeaders.get, toFile: file),
                yield: ())^
            }
        }
        
        return EnvIO { fileSystem in
            let items = IO<FileSystemError, [String]>.var()
            
            return binding(
                items <- fileSystem.items(atPath: path),
                      |<-items.get.traverse(removeHeadersDefinition(atFile:))^.provide(fileSystem),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    internal func copyTestFiles(moduleName: String, template: URL, outputPath: String) -> EnvIO<FileSystem, FileSystemError, ()> {
        let files = ["API+XCTest.swift", "API+Error.swift", "APIConfigTesting.swift", "StubURL.swift"]
        
        return EnvIO { fileSystem in
            binding(
                |<-fileSystem.copy(items: files, from: template.path, to: outputPath),
                |<-files.traverse { file in self.fixTestFile(moduleName: moduleName, fileName: file, outputPath: outputPath).provide(fileSystem) },
                yield: ())
        }^
    }
    
    internal func fixTestFile(moduleName: String, fileName: String, outputPath: String) -> EnvIO<FileSystem, FileSystemError, ()> {
        let content = IO<FileSystemError, String>.var()
        let fixedContent = IO<FileSystemError, String>.var()
        let path = outputPath + "/" + fileName
        
        return EnvIO { fileSystem in
            binding(
                content <- fileSystem.readFile(atPath: path),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: moduleName)),
                |<-fileSystem.write(content: fixedContent.get, toFile: path),
                yield: ())
        }
    }
}
