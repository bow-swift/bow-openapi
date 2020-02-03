//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator
import SnapshotTesting

extension Snapshotting where Value == URL, Format == String {
    
    static func generated(file focus: String, module: String = "", _ file: StaticString = #file) -> Snapshotting<URL, String> {
        func environment(named: String) -> Environment {
            Environment(log: URL(fileURLWithPath: "/tmp/test\(named).log"), fileSystem: MacFileSystem(), generator: SwaggerClientGenerator())
        }
        
        var strategy = Snapshotting<String, String>.lines.pullback { (url: URL) -> String in
            let testName = "\(file.string.filename.removeExtension)-focusIn\(focus.removeExtension)"
            let directory = URL.temp(subfolder: testName)
            let either = APIClient.bow(moduleName: module, scheme: url, output: directory, template: URL.templates)
                                  .provide(environment(named: testName))
                                  .unsafeRunSyncEither()
            
            guard either.isRight else {
                return "error: \(either.leftValue): run bow openAPI in scheme: '\(url.path)', output: '\(directory.path)', template: '\(URL.templates.path)'"
            }
            
            let focusURL = directory.find(item: focus)
            let content = focusURL.flatMap { url in try? String(contentsOf: url, encoding: .utf8) }
            return content ?? "error: get the content file '\(focusURL?.path ?? focus)' in directory '\(directory.path)'"
        }
        strategy.pathExtension = "swift"
        
        return strategy
    }
}
