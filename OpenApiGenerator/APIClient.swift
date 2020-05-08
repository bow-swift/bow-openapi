//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public enum APIClient {
    
    public static func bow(moduleName: String, schema: String, output: String) -> EnvIO<Environment, APIClientError, String> {
        let env = EnvIO<Environment, APIClientError, Environment>.var()
        let templates = EnvIO<Environment, APIClientError, URL>.var()
        let generated = EnvIO<Environment, APIClientError, String>.var()
        
        return binding(
                 env <- .ask(),
           templates <- env.get.generator.getTemplates(),
           generated <- bow(moduleName: moduleName, scheme: schema, output: output, templates: templates.get),
        yield: generated.get)^
    }
    
    public static func bow(moduleName: String, scheme: String, output: String, templates: URL) -> EnvIO<Environment, APIClientError, String> {
        let outputURL = URL(fileURLWithPath: output.expandingTildeInPath)
        let schemeURL = URL(fileURLWithPath: scheme.expandingTildeInPath)
        let module = OpenAPIModule(name: moduleName,
                                   url: outputURL,
                                   schema: schemeURL,
                                   templates: templates)
        
        return bow(module: module)
    }
    
    public static func bow(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, String> {
        let env = EnvIO<Environment, APIClientError, Environment>.var()
        let validated = EnvIO<Environment, APIClientError, OpenAPIModule>.var()
        
        return binding(
                  env <- .ask(),
            validated <- validate(module: module),
                      |<-createStructure(module: validated.get),
                      |<-env.get.generator.generate(module: validated.get),
                      |<-createSwiftPackage(module: validated.get),
        yield: "RENDER SUCCEEDED")^
    }
    
    // MARK: attributes
    private static func validate(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, OpenAPIModule> {
        EnvIO.invoke { env in
            guard env.fileSystem.exist(item: module.schema) else {
                throw APIClientError(operation: "validate(schema:output:)",
                                    error: GeneratorError.invalidParameters)
            }
            
            return module
        }
    }
    
    // MARK: steps
    internal static func createStructure(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        EnvIO { env in
            guard !env.fileSystem.exist(item: module.url) else {
                return .raiseError(APIClientError(operation: "createStructure(atPath:)", error: GeneratorError.structure))^
            }
            
            return env.fileSystem.createDirectory(atPath: module.url.path, withIntermediateDirectories: true)^
                .followedBy(env.fileSystem.createDirectory(atPath: module.sources.path))^
                .followedBy(env.fileSystem.createDirectory(atPath: module.tests.path))^
                .mapError { _ in APIClientError(operation: "createStructure(atPath:)", error: GeneratorError.structure) }
        }
    }
    
    internal static func createSwiftPackage(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        func installPackage(module: OpenAPIModule) -> EnvIO<FileSystem, FileSystemError, Void> {
            EnvIO { fileSystem in
                fileSystem.copy(item: "Package.swift", from: module.templates.path, to: module.url.path)^
            }
        }
        
        func updatePackageName(module: OpenAPIModule) -> EnvIO<FileSystem, FileSystemError, Void> {
            EnvIO { fileSystem in
                let content = IO<FileSystemError, String>.var()
                let fixedContent = IO<FileSystemError, String>.var()
                let output = module.url.appendingPathComponent("Package.swift")
                
                return binding(
                         content <- fileSystem.readFile(atPath: output.path),
                    fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: module.name)),
                                 |<-fileSystem.write(content: fixedContent.get, toFile: output.path),
                yield: ())^
            }
        }
        
        return installPackage(module: module)
            .followedBy(updatePackageName(module: module))^
            .mapError(FileSystemError.toAPIClientError)
            .contramap(\.fileSystem)^
    }
}
