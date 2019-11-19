//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public struct OutputPath {
    let sources: String
    let tests: String
}

public protocol ClientGenerator {
    func generate(moduleName: String, schemePath: String, outputPath: OutputPath, templatePath: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()>
}
