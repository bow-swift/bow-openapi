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
            binding(
                |<-createStructure(atPath: output).provide(env.fileSystem),
                |<-env.generator.generate(schemePath: scheme,
                                          outputPath: OutputPath(sources: "\(output)/Sources", tests: "\(output)/XCTest"),
                                          templatePath: templatePath,
                                          logPath: env.logPath).provide(env.fileSystem),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    // MARK: attributes
    private static func getTemplatePath() -> IO<APIClientError, String> {
        guard let template = Bundle(path: "bow/openapi/templates")?.resourcePath else {
            return IO.raiseError(APIClientError(operation: "getTemplatePath()", error: GeneratorError.templateNotFound))^
        }
        
        return IO.pure(template)^
    }
    
    // MARK: steps
    private static func createStructure(atPath path: String) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { (fileSystem: FileSystem) in
            fileSystem.removeDirectory(path).handleError({ _ in })^
                      .followedBy(fileSystem.createDirectory(atPath: path))^
                      .followedBy(fileSystem.createDirectory(atPath: "\(path)/Sources"))^
                      .followedBy(fileSystem.createDirectory(atPath: "\(path)/XCTest"))^
                      .mapLeft { _ in APIClientError(operation: "createStructure(atPath:)", error: GeneratorError.structure) }
        }
    }
}