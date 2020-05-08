//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator
import SnapshotTesting
import Bow
import BowEffects

extension Snapshotting where Value == URL, Format == String {
    
    static func generated(file focus: String, moduleName: String = "", _ file: StaticString = #file) -> Snapshotting<URL, String> {
        func environment(named: String) -> Environment {
            Environment(logPath: "/tmp/test\(named).log", fileSystem: MacFileSystem(), generator: SwaggerClientGenerator())
        }
        
        var strategy = Snapshotting<String, String>.lines.pullback { (url: URL) -> String in
            let testName = "\(file.string.filename.removeExtension)-focusIn\(focus.removeExtension)"
            let env = environment(named: testName)
            let directory = URL.temp(subfolder: testName)
            let apiClientIO = APIClient.bow(moduleName: moduleName, scheme: url.path, output: directory.path, templates: URL.templates)
            let removeDirectoryIO: EnvIO<Environment, APIClientError, Void> = env.fileSystem.removeDirectory(directory.path)
                .handleError { _ in }^
                .mapError { e in e as! APIClientError }^.env()
                
            let either = removeDirectoryIO.followedBy(apiClientIO)^.provide(env).unsafeRunSyncEither()
            
            guard either.isRight else {
                return  """
                        error: \(either.leftValue). Run bow openAPI using:
                            - Scheme: \(url.path)
                            - Output: \(directory.path)
                            - Template: \(URL.templates.path)
                        """
            }
            
            let focusURL = directory.find(item: focus)
            let content = focusURL.flatMap { url in try? String(contentsOf: url, encoding: .utf8) }
            return content ?? "error: get the content file '\(focusURL?.path ?? focus)' in directory '\(directory.path)'"
        }
        strategy.pathExtension = "swift"
        
        return strategy
    }
}
