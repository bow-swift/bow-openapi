//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public enum APIClient {
    public static func bow(scheme: String, output: String) -> EnvIO<Environment, APIClientError, String> {
        EnvIO { env in
            let template = IO<APIClientError, String>.var()
            return binding(
                template <- getTemplatePath(),
                         |<-bow(scheme: scheme, output: output, templatePath: template.get).provide(env),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    public static func bow(scheme: String, output: String, templatePath: String) -> EnvIO<Environment, APIClientError, String> {
        EnvIO { env in
            let outputPath = OutputPath(sources: "\(output)/Sources", tests: "\(output)/XCTest")
            
            return binding(
                |<-createStructure(outputPath: outputPath).provide(env.fileSystem),
                |<-env.generator.generate(schemePath: scheme,
                                          outputPath: outputPath,
                                          templatePath: templatePath,
                                          logPath: env.logPath).provide(env.fileSystem),
                |<-createSwiftPackage(outputPath: output, templatePath: templatePath).provide(env.fileSystem),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    // MARK: attributes
    private static func getTemplatePath() -> IO<APIClientError, String> {
        let libPath = "/usr/local/lib"
        let templateSource1 = Bundle(path: "bow/openapi/templates").toOption()
        let templateSource2 = Bundle(path: "\(libPath)/bow/openapi/templates").toOption()
        
        guard let bundle = templateSource1.orElse(templateSource2).toOptional(),
              let template = bundle.resourcePath else {
            return IO.raiseError(APIClientError(operation: "getTemplatePath()", error: GeneratorError.templateNotFound))^
        }
        
        return IO.pure(template)^
    }
    
    // MARK: steps
    internal static func createStructure(outputPath: OutputPath) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            let parentPath = outputPath.sources.parentPath
            
            return fileSystem.removeDirectory(parentPath).handleError({ _ in })^
                             .followedBy(fileSystem.createDirectory(atPath: parentPath))^
                             .followedBy(fileSystem.createDirectory(atPath: outputPath.sources))^
                             .followedBy(fileSystem.createDirectory(atPath: outputPath.tests))^
                             .mapLeft { _ in APIClientError(operation: "createStructure(atPath:)", error: GeneratorError.structure) }
        }
    }
    
    internal static func createSwiftPackage(outputPath: String, templatePath: String) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            fileSystem.copy(item: "Package.swift", from: templatePath, to: outputPath)^
        }.mapError(FileSystemError.toAPIClientError)
    }
}
