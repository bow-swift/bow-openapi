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
                |<-removeFiles("\(output)/Cartfile", "\(output)/git_push.sh"),
                |<-removeFiles("\(output)/SwaggerClient.podspec", "\(output)/SwaggerClient", "\(output)/.swagger-codegen", "\(output)/.swagger-codegen-ignore"),
                |<-removeFiles("\(output)/JSONEncodableEncoding.swift", "\(output)/JSONEncodingHelper.swift", "\(output)/AlamofireImplementations.swift", "\(output)/Models.swift"),
                
                |<-fixSignatureParameters(atFolder: "\(output)/APIs"),
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
        func copy(itemPath: String, from input: String, to output: String) -> IO<Error, ()> {
            FileManager.default.copyItemIO(atPath: "\(input)/\(itemPath)", toPath: "\(output)/\(itemPath)")
        }
        
        func copy(items: [String], from input: String, to output: String) -> IO<Error, ()> {
            sequence(items.map { itemPath in
                copy(itemPath: itemPath, from: input, to: output)
            }).void()^
        }
        
        let items = IO<Error, [String]>.var()
        
        return binding(
            items <- FileManager.default.contentsOfDirectoryIO(atPath: input),
            |<-copy(items: items.get, from: input, to: output),
        yield: ())^.mapLeft { _ in .moveOperation(input: input, output: output) }
    }
    
    private static func removeFiles(_ files: String...) -> IO<APIClientError, ()> {
        let result = files.map { file in
                        FileManager.default.removeItemIO(atPath: file)
                                           .mapLeft { _ in APIClientError.removeOperation(file: file) }
        }
        
        return sequence(result).void()^
    }
    
    private static func fixSignatureParameters(atFolder path: String) -> IO<APIClientError, ()> {
        func fixSignatureParameters(toFiles files: [String]) -> IO<APIClientError, ()> {
            sequence(files.map(fixSignatureParameters(atFile:))).void()^
        }
        
        func fixSignatureParameters(atFile path: String) -> IO<APIClientError, ()> {
            IO.invoke {
                do {
                    let content = try String(contentsOfFile: path)
                    let modified = content.replacingOccurrences(of: "(, ", with: "(")
                    try modified.write(toFile: path, atomically: true, encoding: .utf8)
                } catch {
                    throw APIClientError.updateOperation(file: path)
                }
            }
        }
        
        let items = IO<APIClientError, [String]>.var()
        
        return binding(
            items <- FileManager.default.contentsOfDirectoryIO(atPath: path).mapLeft {_ in .structure },
            items <- items.get.map { item in "\(path)/\(item)" },
                 |<-fixSignatureParameters(toFiles: items.get),
            yield: ()
        )^
    }
    
    // MARK: Helpers
    private static func sequence<E: Error, A>(_ x: [IO<E, A>]) -> IO<E, [A]> {
        x.reduce(IO<E, [A]>.pure([])^) { partial, next in
            partial.flatMap { array in next.map { item in array + [item] }}^
        }
    }
    
}
