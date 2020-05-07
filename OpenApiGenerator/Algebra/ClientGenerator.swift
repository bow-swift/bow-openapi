//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public struct OutputPath {
    let sources: String
    let tests: String
}

public protocol ClientGenerator {
    func getTemplates() -> EnvIO<FileSystem, APIClientError, URL>
    func generate(moduleName: String, schemePath: String, outputPath: OutputPath, template: URL, logPath: String) -> EnvIO<FileSystem, APIClientError, Void>
}
