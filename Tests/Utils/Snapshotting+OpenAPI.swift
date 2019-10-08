//  Copyright © 2019 The Bow Authors.

import Foundation
import SnapshotTesting
import Bow
import BowEffects
import Generator

extension Snapshotting where Value == URL, Format == String {
    
    static func generatedCode(_ focus: String) -> Snapshotting<URL, String> {
        var strategy = Snapshotting<String, String>.lines.pullback { (url: URL) -> String in
            let environment = Environment(logPath: "/tmp/test-\(focus).log", fileSystem: MacFileSystem(), generator: SwaggerClientGenerator())
            let io = APIClient.bow(scheme: url.path, output: "/tmp")
                              .provide(environment)
            return ""
        }
        strategy.pathExtension = "swift"
        return strategy
    }
}
