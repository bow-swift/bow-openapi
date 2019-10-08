//  Copyright © 2019 The Bow Authors.

import Foundation
import SnapshotTesting
import Bow
import BowEffects
import BowOpenAPI

extension Snapshotting where Value == URL, Format == String {
    
    static func generatedCode(_ focus: String) -> Snapshotting<URL, String> {
        var strategy = Snapshotting<String, String>.lines.pullback { (url: URL) -> String in
            fatalError()
        }
        strategy.pathExtension = "swift"
        return strategy
    }
}
