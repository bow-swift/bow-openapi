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
              |<-self.fixSignatureParameters(filesAt: module.sources.appendingPathComponent("APIs")),
              |<-self.renderHelpersForHeaders(filesAt: module.sources.appendingPathComponent("APIs"),
                                              intoFile: module.sources.appendingPathComponent("APIs.swift")),
              |<-self.removeHeadersDefinition(filesAt: module.sources.appendingPathComponent("APIs")),
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

    // MARK: - internal methods <generator>
    internal func swaggerGenerator(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        EnvIO.invoke { env in
            #if os(Linux)
            let result = run("java", args: ["-jar", "/usr/local/bin/swagger-codegen-cli.jar"] + ["generate", "--lang", "swift4", "--input-spec", "\(module.schema.path)", "--output", "\(module.sources.path)", "--template-dir", "\(module.templates.path)"])
            #else
            let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(module.schema.path)", "--output", "\(module.sources.path)", "--template-dir", "\(module.templates.path)"]) { settings in
                settings.execution = .log(file: env.logPath)
            }
            #endif
            
            let hasError = result.exitStatus != 0 || result.stdout.contains("ERROR")
            if hasError { throw APIClientError(operation: "swaggerGenerator(scheme:output:template:logPath:)", error: GeneratorError.generator) }
        }
    }
    
    // MARK: reorganize files
    internal func reorganizeFiles(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        let env = EnvIO<Environment, APIClientError, Environment>.var()
        
        let invalidFiles = ["Cartfile", "AlamofireImplementations.swift", "Models.swift", "git_push.sh", "SwaggerClient.podspec", "SwaggerClient", ".swagger-codegen", ".swagger-codegen-ignore", "JSONEncodableEncoding.swift", "JSONEncodingHelper.swift"]
        
        let swaggerFiles = module.sources
            .appendingPathComponent("SwaggerClient")
            .appendingPathComponent("Classes")
            .appendingPathComponent("Swaggers")
        
        return binding(
            env <- .ask(),
            |<-env.get.fileSystem.moveFiles(in: swaggerFiles, to: module.sources).toAPIClientEnv(),
            |<-env.get.fileSystem.remove(in: module.sources, files: invalidFiles).toAPIClientEnv(),
            |<-env.get.fileSystem.rename(with: "APIConfiguration.swift", item: module.sources.appendingPathComponent("APIHelper.swift")).toAPIClientEnv(),
            |<-self.copyTestFiles(module: module),
        yield: ())^
    }
    
    internal func copyTestFiles(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        let files = ["API+XCTest.swift", "API+Error.swift", "APIConfigTesting.swift", "StubURL.swift"]
        let fixTextFilename = module |> fixTestFile
        let env = EnvIO<Environment, APIClientError, Environment>.var()
        
        return binding(
            env <- .ask(),
                |<-env.get.fileSystem.copy(items: files, from: module.templates, to: module.tests).toAPIClientEnv(),
                |<-files.traverse(fixTextFilename),
        yield: ())^
    }
    
    // MARK: update files content
    internal func fixTestFile(module: OpenAPIModule, filename: String) -> EnvIO<Environment, APIClientError, Void> {
        EnvIO { env in
            let content = IO<FileSystemError, String>.var()
            let fixedContent = IO<FileSystemError, String>.var()
            let file = module.tests.appendingPathComponent(filename)
            
            return binding(
                    content <- env.fileSystem.readFile(at: file),
               fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: module.name)),
                            |<-env.fileSystem.write(content: fixedContent.get, toFile: file),
            yield: ())
        }.mapError(FileSystemError.toAPIClientError)
    }
    
    internal func fixSignatureParameters(filesAt directory: URL) -> EnvIO<Environment, APIClientError, Void> {
        let env = EnvIO<Environment, APIClientError, Environment>.var()
        let items = EnvIO<Environment, APIClientError, [URL]>.var()
        
        return binding(
              env <- .ask(),
            items <- env.get.fileSystem.items(at: directory).toAPIClientEnv(),
                  |<-self.fixSignatureParameters(toFiles: items.get),
        yield: ())^
    }
    
    internal func fixSignatureParameters(toFiles files: [URL]) -> EnvIO<Environment, APIClientError, Void> {
        files.traverse(fixSignatureParameters(atFile:)).void()^
    }
    
    internal func fixSignatureParameters(atFile item: URL) -> EnvIO<Environment, APIClientError, Void> {
        EnvIO { env in
            let content = IO<FileSystemError, String>.var()
            let fixedContent = IO<FileSystemError, String>.var()
            
            return binding(
                content <- env.fileSystem.readFile(at: item),
            fixedContent <- IO.pure(content.get.replacingOccurrences(of: "(, ", with: "(")
                                               .replacingOccurrences(of: "(,", with: "(")),
                         |<-env.fileSystem.write(content: fixedContent.get, toFile: item),
            yield: ())
        }.mapError(FileSystemError.toAPIClientError)
    }
    
    // MARK: render files
    private var regexHeaders: String { "(?s)(/\\* API.CONFIG.HEADERS.*\n).*(\\*/)" }
    
    internal func renderHelpersForHeaders(filesAt directory: URL, intoFile output: URL) -> EnvIO<Environment, APIClientError, Void> {
        typealias HeaderValue = (type: String, header: String)

        func headerInformation(content: String) -> IO<FileSystemError, [String: HeaderValue]> {
            guard let plainHeaders = content.substring(pattern: regexHeaders)?.ouput.components(separatedBy: "\n") else {
                return IO.raiseError(FileSystemError.invalidContent(info: "::headerInformation"))^
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
            let items = IO<FileSystemError, [URL]>.var()
            let contents = IO<FileSystemError, [String]>.var()
            let headers = IO<FileSystemError, [[String: HeaderValue]]>.var()
            let flattenHeaders = IO<FileSystemError, [String: HeaderValue]>.var()
            let helpers = IO<FileSystemError, String>.var()
            let fileContent = IO<FileSystemError, String>.var()

            return binding(
                        items <- env.fileSystem.items(at: directory),
                     contents <- items.get.traverse(env.fileSystem.readFile(at:)),
                      headers <- contents.get.traverse(headerInformation),
               flattenHeaders <- IO.pure(headers.get.combineAll()),
                      helpers <- IO.pure(renderHelpers(headers: flattenHeaders.get)),
                  fileContent <- env.fileSystem.readFile(at: output),
                              |<-env.fileSystem.write(content: "\(fileContent.get)\n\n\(helpers.get)", toFile: output),
            yield: ())^.mapError(FileSystemError.toAPIClientError)
        }
    }
    
    internal func removeHeadersDefinition(filesAt directory: URL) -> EnvIO<Environment, APIClientError, Void> {
        func removeHeadersDefinition(atFile file: URL) -> EnvIO<FileSystem, FileSystemError, Void> {
            EnvIO { fileSystem in
                let content = IO<FileSystemError, String>.var()
                let headers = IO<FileSystemError, String>.var()
                let contentWithoutHeaders = IO<FileSystemError, String>.var()

                return binding(
                                  content <- fileSystem.readFile(at: file),
                                  headers <- IO.pure(content.get.substring(pattern: self.regexHeaders)?.ouput ?? ""),
                    contentWithoutHeaders <- IO.pure(content.get.clean(headers.get)),
                                          |<-fileSystem.write(content: contentWithoutHeaders.get, toFile: file),
                yield: ())^
            }
        }
        
        let env = EnvIO<Environment, FileSystemError, Environment>.var()
        let items = EnvIO<Environment, FileSystemError, [URL]>.var()
        
        return binding(
              env <- .ask(),
            items <- env.get.fileSystem.items(at: directory).env(),
                  |<-items.get.traverse(removeHeadersDefinition(atFile:))^.contramap(\.fileSystem),
        yield: ())^
            .mapError(FileSystemError.toAPIClientError)
    }
}
