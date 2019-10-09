//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

struct OutputPath {
    let sources: String
    let tests: String
}

protocol ClientGenerator {
    func generate(schemePath: String, outputPath: OutputPath, templatePath: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()>
}
