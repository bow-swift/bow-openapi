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
                
                 |<-fixSignatureParameters(filesAt: "\(output)/APIs"),
                 |<-writeHelpersForHeaders(filesAt: "\(output)/APIs", inFile: "\(output)/APIs.swift"),
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
        func copy(items: [String], from input: String, to output: String) -> IO<APIClientError, ()> {
            sequence(items.map { (itemPath: String) in
                copy(item: itemPath.filename, from: input, to: output)
            }).void()^
        }
        
        func copy(item: String, from input: String, to output: String) -> IO<APIClientError, ()> {
            FileManager.default.copyItemIO(atPath: "\(input)/\(item)", toPath: "\(output)/\(item)")
                               .mapLeft { _ in .moveOperation(input: input, output: output) }
        }
        
        let items = IO<APIClientError, [String]>.var()
        
        return binding(
            items <- files(atPath: input),
                  |<-copy(items: items.get, from: input, to: output),
            yield: ()
        )^
    }
    
    private static func removeFiles(_ files: String...) -> IO<APIClientError, ()> {
        let result = files.map { file in
                        FileManager.default.removeItemIO(atPath: file)
                                           .mapLeft { _ in APIClientError.removeOperation(file: file) }
        }
        
        return sequence(result).void()^
    }
    
    private static func fixSignatureParameters(filesAt path: String) -> IO<APIClientError, ()> {
        func fixSignatureParameters(toFiles files: [String]) -> IO<APIClientError, ()> {
            sequence(files.map(fixSignatureParameters(atFile:))).void()^
        }
        
        func fixSignatureParameters(atFile path: String) -> IO<APIClientError, ()> {
            let content = IO<APIClientError, String>.var()
            
            return binding(
                content <- readFile(atPath: path),
                content <- content.get.replacingOccurrences(of: "(, ", with: "("),
                        |<-write(content: content.get, atPath: path),
                yield: ()
            )^.mapLeft { _ in .updateOperation(file: path)}
        }
        
        let items = IO<APIClientError, [String]>.var()
        
        return binding(
            items <- files(atPath: path),
                  |<-fixSignatureParameters(toFiles: items.get),
            yield: ()
        )^
    }
    
    private static func writeHelpersForHeaders(filesAt path: String, inFile output: String) -> IO<APIClientError, ()> {
        func headerInformation(content: String) -> IO<APIClientError, [String: String]> {
            let regex = "(?s)(/\\* API.CONFIG.HEADERS.*\n).*(\\*/)"
            guard let plainHeaders = content.substring(pattern: regex)?.ouput.components(separatedBy: "\n") else { return IO.raiseError(APIClientError.structure)^ }
            
            let headers = plainHeaders.compactMap { string -> [String: String]? in
                let components = string.components(separatedBy: ":")
                guard components.count == 2 else { return nil }
                return [components[0].trimmingWhitespaces: components[1].trimmingWhitespaces]
            }
            
            return IO.pure(flatten(headers))^
        }
        
        func renderHelpers(headers: [String: String]) -> String {
            guard headers.count > 0 else { return "" }
            
            let methods = headers.map { key, type in
                """
                
                    func withHeader(\(key): \(type)) -> API.Config {
                        self.copy(headers: self.headers.combine(["\(key)": \(key)]))
                    }
                """
            }
            
            return """
                   extension API.Config {
                   \(methods.reduce("", +))
                   }
                   """
        }
        
        let items = IO<APIClientError, [String]>.var()
        let contents = IO<APIClientError, [String]>.var()
        let headers = IO<APIClientError, [[String: String]]>.var()
        let flattenHeaders = IO<APIClientError, [String: String]>.var()
        let helpers = IO<APIClientError, String>.var()
        let file = IO<APIClientError, String>.var()
        
        return binding(
               items <- files(atPath: path),
            contents <- sequence(items.get.map(readFile(atPath:))),
             headers <- sequence(contents.get.map(headerInformation)),
      flattenHeaders <- flatten(headers.get),
             helpers <- renderHelpers(headers: flattenHeaders.get),
                file <- readFile(atPath: output),
                     |<-write(content: "\(file.get)\n\n\(helpers.get)", atPath: output),
        yield: ())^
    }
    
    // MARK: Helpers
    private static func sequence<E: Error, A>(_ x: [IO<E, A>]) -> IO<E, [A]> {
        x.reduce(IO<E, [A]>.pure([])^) { partial, next in
            partial.flatMap { array in next.map { item in array + [item] }}^
        }
    }
    
    private static func flatten(_ dict: [[String: String]]) -> [String: String] {
        dict.reduce([:]) { partial, next in partial.combine(next) }
    }
    
    private static func files(atPath path: String) -> IO<APIClientError, [String]> {
        FileManager.default.contentsOfDirectoryIO(atPath: path)
                           .mapLeft {_ in .structure }
                           .map { files in files.map({ file in "\(path)/\(file)"}) }^
    }
    
    private static func readFile(atPath path: String) -> IO<APIClientError, String> {
        IO.invoke {
            do {
                return try String(contentsOfFile: path)
            } catch {
                throw APIClientError.read(file: path)
            }
        }
    }
    
    private static func write(content: String, atPath path: String) -> IO<APIClientError, ()> {
        IO.invoke {
            do {
                try content.write(toFile: path, atomically: true, encoding: .utf8)
            } catch {
                throw APIClientError.write(file: path)
            }
        }
    }
    
}
