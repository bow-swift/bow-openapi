//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import Swiftline

protocol ClientGenerator {
    func generate(scheme: String, output: String, template: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()>
}

class SwaggerClientGenerator: ClientGenerator {
    func generate(scheme: String, output: String, template: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()> {
        return binding(
              |<-self.swaggerGenerator(scheme: scheme, output: output, template: template, logPath: logPath),
              |<-self.reorganizeFiles(in: output),
              |<-self.fixSignatureParameters(filesAt: "\(output)/APIs"),
              |<-self.renderHelpersForHeaders(filesAt: "\(output)/APIs", inFile: "\(output)/APIs.swift"),
              |<-self.removeHeadersDefinition(filesAt: "\(output)/APIs"),
        yield: ())^
    }
    
    private func swaggerGenerator(scheme: String, output: String, template: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()> {
        func runSwagger() -> IO<APIClientError, ()> {
            IO.invoke {
                let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(scheme)", "--output", "\(output)", "--template-dir", "\(template)"]) { settings in
                    settings.execution = .log(file: logPath)
                }
                
                let hasError = result.exitStatus != 0 || result.stdout.contains("ERROR")
                if hasError { throw APIClientError.generator }
            }
        }
        
        return EnvIO { _ in runSwagger() }
    }
    
    private func reorganizeFiles(in output: String) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { fileSystem in
            binding(
                |<-fileSystem.move(from: "\(output)/SwaggerClient/Classes/Swaggers", to: output),
                |<-fileSystem.remove(from: output, files: "Cartfile", "AlamofireImplementations.swift", "Models.swift", "git_push.sh", "SwaggerClient.podspec", "SwaggerClient", ".swagger-codegen", ".swagger-codegen-ignore", "JSONEncodableEncoding.swift", "JSONEncodingHelper.swift"),
            yield: ())
        }
    }
    
    private func fixSignatureParameters(filesAt path: String) -> EnvIO<FileSystem, APIClientError, ()> {
        func fixSignatureParameters(toFiles files: [String]) -> EnvIO<FileSystem, APIClientError, ()> {
            files.traverse(fixSignatureParameters(atFile:)).void()^
        }
        
        func fixSignatureParameters(atFile path: String) -> EnvIO<FileSystem, APIClientError, ()> {
            EnvIO { fileSystem in
                let content = IO<APIClientError, String>.var()
                let fixedContent = IO<APIClientError, String>.var()
                
                return binding(
                     content <- fileSystem.readFile(atPath: path),
                fixedContent <- IO.pure(content.get.replacingOccurrences(of: "(, ", with: "(")),
                             |<-fileSystem.write(content: fixedContent.get, atPath: path),
                yield: ())^.mapLeft { _ in .updateOperation(file: path)}
            }
        }
        
        return EnvIO { fileSystem in
            let items = IO<APIClientError, [String]>.var()
            
            return binding(
                items <- fileSystem.files(atPath: path),
                      |<-fixSignatureParameters(toFiles: items.get).provide(fileSystem),
                yield: ()
            )^
        }
    }
    
    private var regexHeaders: String { "(?s)(/\\* API.CONFIG.HEADERS.*\n).*(\\*/)" }
    
    private func renderHelpersForHeaders(filesAt path: String, inFile output: String) -> EnvIO<FileSystem, APIClientError, ()> {
        typealias HeaderValue = (type: String, header: String)
        
        func headerInformation(content: String) -> IO<APIClientError, [String: HeaderValue]> {
            guard let plainHeaders = content.substring(pattern: regexHeaders)?.ouput.components(separatedBy: "\n") else { return IO.raiseError(APIClientError.structure)^ }
            
            let headers = plainHeaders.compactMap { string -> [String: HeaderValue]? in
                let components = string.components(separatedBy: ":")
                guard components.count == 3 else { return nil }
                return [components[0].trimmingWhitespaces: (components[1].trimmingWhitespaces, components[2].trimmingWhitespaces)]
            }
            
            return IO.pure(headers.fold())^
        }
        
        func renderHelpers(headers: [String: HeaderValue]) -> String {
            guard headers.count > 0 else { return "" }
            
            let methods = headers.map { (arg) -> String in
                let (key, (type, header)) = arg
                return """
                
                    func withHeader(\(key): \(type)) -> API.Config {
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
            let items = IO<APIClientError, [String]>.var()
            let contents = IO<APIClientError, [String]>.var()
            let headers = IO<APIClientError, [[String: HeaderValue]]>.var()
            let flattenHeaders = IO<APIClientError, [String: HeaderValue]>.var()
            let helpers = IO<APIClientError, String>.var()
            let file = IO<APIClientError, String>.var()
            
            return binding(
                         items <- fileSystem.files(atPath: path),
                      contents <- items.get.traverse(fileSystem.readFile(atPath:)),
                       headers <- contents.get.traverse(headerInformation),
                flattenHeaders <- IO.pure(headers.get.fold()),
                       helpers <- IO.pure(renderHelpers(headers: flattenHeaders.get)),
                          file <- fileSystem.readFile(atPath: output),
                               |<-fileSystem.write(content: "\(file.get)\n\n\(helpers.get)", atPath: output),
            yield: ())^
        }
    }
    
    func removeHeadersDefinition(filesAt path: String) -> EnvIO<FileSystem, APIClientError, ()> {
        func removeHeadersDefinition(atFile file: String) -> EnvIO<FileSystem, APIClientError, ()> {
            EnvIO { fileSystem in
                let content = IO<APIClientError, String>.var()
                let headers = IO<APIClientError, String>.var()
                let contentWithoutHeaders = IO<APIClientError, String>.var()
                
                return binding(
                                  content <- fileSystem.readFile(atPath: file),
                                  headers <- IO.pure(content.get.substring(pattern: self.regexHeaders)?.ouput ?? ""),
                    contentWithoutHeaders <- IO.pure(content.get.clean(headers.get)),
                                          |<-fileSystem.write(content: contentWithoutHeaders.get, atPath: file),
                yield: ())^
            }
        }
        
        return EnvIO { fileSystem in
            let items = IO<APIClientError, [String]>.var()
            
            return binding(
                items <- fileSystem.files(atPath: path),
                      |<-items.get.traverse(removeHeadersDefinition(atFile:))^.provide(fileSystem),
            yield: ())^
        }
    }
}
