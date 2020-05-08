//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import Swiftline

public class SwaggerClientGenerator: ClientGenerator {
    public init() { }
    
    
    public func generate(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        binding(
              |<-self.swaggerGenerator(module: module),
              |<-self.reorganizeFiles(module: module),
              |<-self.fixSignatureParameters(filesAt: "\(module.sources.path)/APIs"),
              |<-self.renderHelpersForHeaders(filesAt: "\(module.sources.path)/APIs", inFile: "\(module.sources.path)/APIs.swift"),
              |<-self.removeHeadersDefinition(filesAt: "\(module.sources.path)/APIs"),
        yield: ())^
    }
    
    public func getTemplates() -> EnvIO<Environment, APIClientError, URL> {
        EnvIO.invoke { _ in
            let libPath = "/usr/local/lib"
            guard let bundle = Bundle(path: "\(libPath)/bowopenapi/Templates"),
                  let template = bundle.resourcePath else {
                throw APIClientError(operation: "getTemplatePath()", error: GeneratorError.templateNotFound)
            }
            
            return URL(fileURLWithPath: template)
        }
    }
    
    internal func swaggerGenerator(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        EnvIO.invoke { env in
            #if os(Linux)
            let result = run("java", args: ["-jar", "/usr/local/bin/swagger-codegen-cli.jar"] + ["generate", "--lang", "swift4", "--input-spec", "\(module.scheme.path)", "--output", "\(module.sources.path)", "--template-dir", "\(module.templates.path)"])
            #else
            let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(module.schema.path)", "--output", "\(module.sources.path)", "--template-dir", "\(module.templates.path)"]) { settings in
                settings.execution = .log(file: env.logPath)
            }
            #endif
            
            let hasError = result.exitStatus != 0 || result.stdout.contains("ERROR")
            if hasError { throw APIClientError(operation: "swaggerGenerator(scheme:output:template:logPath:)", error: GeneratorError.generator) }
        }
    }
    
    
    
    
    
    internal func reorganizeFiles(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, ()> {
        EnvIO { env in
            binding(
                |<-env.fileSystem.moveFiles(in: "\(module.sources.path)/SwaggerClient/Classes/Swaggers", to: module.sources.path),
                |<-env.fileSystem.remove(from: module.sources.path, files: "Cartfile", "AlamofireImplementations.swift", "Models.swift", "git_push.sh", "SwaggerClient.podspec", "SwaggerClient", ".swagger-codegen", ".swagger-codegen-ignore", "JSONEncodableEncoding.swift", "JSONEncodingHelper.swift"),
                |<-env.fileSystem.rename("APIConfiguration.swift", itemAt: "\(module.sources.path)/APIHelper.swift"),
                |<-self.copyTestFiles(moduleName: module.name, template: module.templates, outputPath: module.tests.path).provide(env),
            yield: ())^
        }.mapError(FileSystemError.toAPIClientError)
    }
    
    internal func fixSignatureParameters(filesAt path: String) -> EnvIO<Environment, APIClientError, ()> {
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
        
        return EnvIO { env in
            let items = IO<FileSystemError, [String]>.var()
            
            return binding(
                items <- env.fileSystem.items(atPath: path),
                |<-fixSignatureParameters(toFiles: items.get).provide(env.fileSystem),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    private var regexHeaders: String { "(?s)(/\\* API.CONFIG.HEADERS.*\n).*(\\*/)" }
    
    internal func renderHelpersForHeaders(filesAt path: String, inFile output: String) -> EnvIO<Environment, APIClientError, ()> {
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
        
        return EnvIO { env in
            let items = IO<FileSystemError, [String]>.var()
            let contents = IO<FileSystemError, [String]>.var()
            let headers = IO<FileSystemError, [[String: HeaderValue]]>.var()
            let flattenHeaders = IO<FileSystemError, [String: HeaderValue]>.var()
            let helpers = IO<FileSystemError, String>.var()
            let file = IO<FileSystemError, String>.var()
            
            return binding(
                items <- env.fileSystem.items(atPath: path),
                      contents <- items.get.traverse(env.fileSystem.readFile(atPath:)),
                       headers <- contents.get.traverse(headerInformation),
                flattenHeaders <- IO.pure(headers.get.combineAll()),
                       helpers <- IO.pure(renderHelpers(headers: flattenHeaders.get)),
                          file <- env.fileSystem.readFile(atPath: output),
                               |<-env.fileSystem.write(content: "\(file.get)\n\n\(helpers.get)", toFile: output),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    internal func removeHeadersDefinition(filesAt path: String) -> EnvIO<Environment, APIClientError, ()> {
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
        
        return EnvIO { env in
            let items = IO<FileSystemError, [String]>.var()
            
            return binding(
                items <- env.fileSystem.items(atPath: path),
                |<-items.get.traverse(removeHeadersDefinition(atFile:))^.provide(env.fileSystem),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    internal func copyTestFiles(moduleName: String, template: URL, outputPath: String) -> EnvIO<Environment, FileSystemError, Void> {
        let files = ["API+XCTest.swift", "API+Error.swift", "APIConfigTesting.swift", "StubURL.swift"]
        
        return EnvIO { env in
            binding(
                |<-env.fileSystem.copy(items: files, from: template.path, to: outputPath),
                |<-files.traverse { file in self.fixTestFile(moduleName: moduleName, fileName: file, outputPath: outputPath).provide(env) },
                yield: ())
        }^
    }
    
    internal func fixTestFile(moduleName: String, fileName: String, outputPath: String) -> EnvIO<Environment, FileSystemError, Void> {
        let content = IO<FileSystemError, String>.var()
        let fixedContent = IO<FileSystemError, String>.var()
        let path = outputPath + "/" + fileName
        
        return EnvIO { env in
            binding(
                content <- env.fileSystem.readFile(atPath: path),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: moduleName)),
                |<-env.fileSystem.write(content: fixedContent.get, toFile: path),
                yield: ())
        }
    }
}
