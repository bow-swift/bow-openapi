//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public struct GeneratorOutput {
    let sources: String
    let tests: String
}

public protocol ClientGenerator {
    func generate(schemePath: String, outputPath: GeneratorOutput, templatePath: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()>
}
