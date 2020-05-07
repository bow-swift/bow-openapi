//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public enum APIClient {
    
    public static func bow(moduleName: String, schema: String, output: String) -> EnvIO<Environment, APIClientError, String> {
        let env = EnvIO<Environment, APIClientError, Environment>.var()
        let validated = EnvIO<Environment, APIClientError, String>.var()
        let template = EnvIO<Environment, APIClientError, URL>.var()
        let schema = schema.expandingTildeInPath
        let output = output.expandingTildeInPath
        
        return binding(
                env <- .ask(),
           validated <- validate(schema: schema),
            template <- env.get.generator.getTemplates().contramap(\.fileSystem),
                     |<-bow(moduleName: moduleName, scheme: validated.get, output: output, template: template.get),
        yield: "RENDER SUCCEEDED")^
    }
    
    public static func bow(moduleName: String, scheme: String, output: String, template: URL) -> EnvIO<Environment, APIClientError, String> {
        EnvIO { env in
            let outputPath = OutputPath(sources: "\(output)/Sources",
                                        tests: "\(output)/XCTest")
            
            return binding(
                |<-createStructure(outputPath: outputPath).provide(env.fileSystem),
                |<-env.generator.generate(moduleName: moduleName,
                                          schemePath: scheme,
                                          outputPath: outputPath,
                                          template: template,
                                          logPath: env.logPath).provide(env.fileSystem),
                |<-createSwiftPackage(moduleName: moduleName, outputPath: output, template: template).provide(env.fileSystem),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    // MARK: attributes
    private static func validate(schema: String) -> EnvIO<Environment, APIClientError, String> {
        EnvIO.invoke { _ in
            guard FileManager.default.fileExists(atPath: schema) else {
                throw APIClientError(operation: "validate(schema:output:)",
                                    error: GeneratorError.invalidParameters)
            }
            
            return schema
        }
    }
    
    // MARK: steps
    internal static func createStructure(outputPath: OutputPath) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            let parentPath = outputPath.sources.parentPath
            
            return fileSystem.removeDirectory(parentPath).handleError({ _ in })^
                             .followedBy(fileSystem.createDirectory(atPath: parentPath))^
                             .followedBy(fileSystem.createDirectory(atPath: outputPath.sources))^
                             .followedBy(fileSystem.createDirectory(atPath: outputPath.tests))^
                             .mapError { _ in APIClientError(operation: "createStructure(atPath:)", error: GeneratorError.structure) }
        }
    }
    
    internal static func createSwiftPackage(moduleName: String, outputPath: String, template: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            fileSystem.copy(item: "Package.swift", from: template.path, to: outputPath)^
        }.followedBy(package(moduleName: moduleName, outputPath: outputPath))^
        .mapError(FileSystemError.toAPIClientError)
    }
    
    internal static func package(moduleName: String, outputPath: String) -> EnvIO<FileSystem, FileSystemError, ()> {
        EnvIO { fileSystem in
            let content = IO<FileSystemError, String>.var()
            let fixedContent = IO<FileSystemError, String>.var()
            let path = outputPath + "/Package.swift"
            
            return binding(
                content <- fileSystem.readFile(atPath: path),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: moduleName)),
                |<-fileSystem.write(content: fixedContent.get, toFile: path),
                yield: ()
            )^
        }
    }
}
