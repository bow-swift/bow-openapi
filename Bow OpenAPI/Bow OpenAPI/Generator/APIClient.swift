//  Copyright © 2019 The Bow Authors.

import Foundation
import Swiftline
import Bow
import BowEffects

enum APIClient {
    
    static func bow(scheme: String, output: String) -> IO<APIClientError, String> {
        let template = IO<APIClientError, String>.var()
        
        return binding(
        template <- getTemplatePath(),
                |<-removeDirectory(output: output),
                |<-createDirectory(output: output),
                
                |<-swaggerGenerator(scheme: scheme, output: output, template: template.get, logPath: logPath),
                |<-flattenStructure("\(output)/SwaggerClient/Classes/Swaggers", to: output),
                |<-removeFiles("\(output)/Cartfile", "\(output)/git_push.sh", "\(output)/SwaggerClient.podspec", "\(output)/SwaggerClient"),
                
            yield: "RENDER SUCCEEDED")^
    }
    
    // MARK: - attributes
    private static var logPath: String { "/tmp/bow-openapi.log" }
    
    private static func getTemplatePath() -> IO<APIClientError, String> {
        guard let template = Bundle(path: "bow/openapi/templates")?.resourcePath else {
            return IO<APIClientError, String>.raiseError(APIClientError.templateNotFound)^
        }
        
        return IO<APIClientError, String>.pure(template)^
    }
    
    // MARK: - private methods
    private static func removeDirectory(output: String) -> IO<APIClientError, ()> {
        IO.invoke {
            let outputURL = URL(fileURLWithPath: output, isDirectory: true)
            let _ = try? FileManager.default.removeItem(at: outputURL)
        }
    }
    
    private static func createDirectory(output: String) -> IO<APIClientError, ()> {
        FileManager.default.createDirectoryIO(atPath: output, withIntermediateDirectories: false).mapLeft { _ in .structure }
    }
    
    private static func swaggerGenerator(scheme: String, output: String, template: String, logPath: String) -> IO<APIClientError, ()> {
        IO.invoke {
            let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(scheme)", "--output", "\(output)", "--template-dir", "\(template)"]) { settings in
                settings.execution = .log(file: logPath)
            }
            
            let hasError = result.exitStatus != 0 || result.stdout.contains("ERROR")
            if hasError { throw APIClientError.generator }
        }
    }
    
    private static func flattenStructure(_ input: String, to output: String) -> IO<APIClientError, ()> {
        IO.invoke {
            do {
                try FileManager.default.contentsOfDirectory(atPath: input).forEach { itemPath in
                    try FileManager.default.copyItem(atPath: "\(input)/\(itemPath)", toPath: "\(output)/\(itemPath)")
                }
            } catch {
                throw APIClientError.moveOperation(input: input, output: output)
            }
        }
    }
    
    private static func removeFiles(_ files: String...) -> IO<APIClientError, ()> {
        IO.invoke {
            try files.forEach { file in
                do {
                    try FileManager.default.removeItem(atPath: file)
                } catch {
                    throw APIClientError.removeOperation(file: file)
                }
            }
        }
    }
}




/// APIClient errors
enum APIClientError: Error {
    case structure
    case generator
    case templateNotFound
    case removeOperation(file: String)
    case moveOperation(input: String, output: String)
}

extension APIClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case .structure:
            return "could not create project structure"
        case .generator:
            return "command 'swagger-codegen' failed"
        case .templateNotFound:
            return "templates for generating Bow client have not been found"
        case .removeOperation(let file):
            return "can not remove the file '\(file)'"
        case let .moveOperation(input, output):
            return "can not move items in '\(input)' to '\(output)'"
        }
    }
}
