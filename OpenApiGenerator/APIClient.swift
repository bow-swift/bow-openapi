//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public enum APIClient {
    public static func bow(moduleName: String, scheme: URL, output: URL) -> EnvIO<Environment, APIClientError, String> {
        EnvIO { env in
            let template = IO<APIClientError, URL>.var()
            return binding(
                template <- getTemplatePath(),
                         |<-bow(moduleName: moduleName, scheme: scheme, output: output, template: template.get).provide(env),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    public static func bow(moduleName: String, scheme: URL, output root: URL, template: URL) -> EnvIO<Environment, APIClientError, String> {
        EnvIO { env in
            let project = root.appendingPathComponent(moduleName)
            let output = OutputURL(sources: project.appendingPathComponent("Sources"),
                                   tests: project.appendingPathComponent("XCTest"))
            
            return binding(
                |<-createStructure(output: output).provide(env.fileSystem),
                |<-env.generator.generate(moduleName: moduleName,
                                          scheme: scheme,
                                          output: output,
                                          template: template,
                                          log: env.log).provide(env.fileSystem),
                |<-createSwiftPackage(moduleName: moduleName, output: project, template: template).provide(env.fileSystem),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    // MARK: attributes
    private static func getTemplatePath() -> IO<APIClientError, URL> {
        let libPath = "/usr/local/lib"
        let templateSource1 = Bundle(path: "bow/openapi/templates").toOption()
        let templateSource2 = Bundle(path: "\(libPath)/bow/openapi/templates").toOption()
        
        guard let bundle = templateSource1.orElse(templateSource2).toOptional(),
              let template = bundle.resourcePath else {
            return IO.raiseError(APIClientError(operation: "getTemplatePath()", error: GeneratorError.templateNotFound))^
        }
        
        return IO.pure(URL(fileURLWithPath: template))^
    }
    
    // MARK: steps
    internal static func createStructure(output: OutputURL) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            let emptyProject = fileSystem.remove(item: output.sources.deletingLastPathComponent()).handleError { _ in }
            let createSourcesIO = fileSystem.createDirectory(at: output.sources, withIntermediates: true)
            let createTestsIO = fileSystem.createDirectory(at: output.tests, withIntermediates: true)
            
            return emptyProject.followedBy(createSourcesIO).followedBy(createTestsIO)^
                      .mapLeft { _ in APIClientError(operation: "createStructure(output:)", error: GeneratorError.structure) }
        }
    }
    
    internal static func createSwiftPackage(moduleName: String, output: URL, template: URL) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            fileSystem.copy(item: "Package.swift", from: template, to: output)^
        }.followedBy(package(moduleName: moduleName, output: output))^
         .mapError(FileSystemError.toAPIClientError)
    }
    
    internal static func package(moduleName: String, output: URL) -> EnvIO<FileSystem, FileSystemError, ()> {
        EnvIO { fileSystem in
            let content = IO<FileSystemError, String>.var()
            let fixedContent = IO<FileSystemError, String>.var()
            let package = output.appendingPathComponent("/Package.swift")
            
            return binding(
                     content <- fileSystem.readFile(at: package),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "{{ moduleName }}", with: moduleName)),
                             |<-fileSystem.write(content: fixedContent.get, toFile: package),
            yield: ())^
        }
    }
}
