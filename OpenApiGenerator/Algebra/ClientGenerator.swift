//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public struct OutputURL {
    let sources: URL
    let tests: URL
}

public protocol ClientGenerator {
    func generate(moduleName: String, scheme: URL, output: OutputURL, template: URL, log: URL) -> EnvIO<FileSystem, APIClientError, ()>
}
