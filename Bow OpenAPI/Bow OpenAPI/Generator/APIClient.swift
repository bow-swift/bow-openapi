//  Copyright © 2019 The Bow Authors.

import Foundation
import Swiftline
import Bow
import BowEffects

enum APIClient {
    
    static func bow(scheme: String, output: String) -> Bool {
        let template = IO<APIClientError, String>.var()
        
        let script = binding(
                |<-removeDirectory(output: output),
                |<-createDirectory(output: output),
        template <- templatePath(),
                |<-swaggerGenerator(scheme: scheme, output: output, template: template.get, logPath: logPath),
            yield: ("great!"))^

        let result = try? script.unsafeRunSync()
        print(result ?? "error")
        
        return true
    }
    
    // MARK: - attributes
    private static var logPath: String { "/tmp/bow-openapi.log" }
    
    private static func templatePath() -> IO<APIClientError, String> {
        guard let template = Bundle(path: "bow/openapi/templates")?.resourcePath else {
            return IO<APIClientError, String>.raiseError(APIClientError.templateNotFound)^
        }
        
        return IO<APIClientError, String>.pure(template)^
    }
    
    // MARK: - private methods
    private static func removeDirectory(output: String) -> IO<APIClientError, ()> {
        IO.invoke { () -> Void in
            let outputURL = URL(fileURLWithPath: output, isDirectory: true)
            let _ = try? FileManager.default.removeItem(at: outputURL)
        }
    }
    
    private static func createDirectory(output: String) -> IO<APIClientError, ()> {
        FileManager.default.createDirectoryIO(atPath: output, withIntermediateDirectories: false).mapLeft { _ in .structure }
    }
    
    private static func swaggerGenerator(scheme: String, output: String, template: String, logPath: String) -> IO<APIClientError, ()> {
        IO.invoke { () -> Void in
            let result = run("/usr/local/bin/swagger-codegen", args: ["generate", "--lang", "swift4", "--input-spec", "\(scheme)", "--output", "\(output)", "--template-dir", "\(template)"]) { settings in
                settings.execution = .log(file: logPath)
            }
            
            if result.stdout.contains("ERROR") { throw APIClientError.generator }
        }
    }
}


/// APIClient errors
enum APIClientError: Error {
    case structure
    case generator
    case templateNotFound
}

extension APIClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case .structure:
            return "could not create project structure"
        case .generator:
            return "command 'swagger-codegen' failed"
        default:
            fatalError()
        }
    }
}
