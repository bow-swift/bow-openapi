//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

protocol ClientGenerator {
    func generate(scheme: String, output: String, template: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()>
}
