//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public protocol ClientGenerator {
    func getTemplates() -> EnvIO<Environment, APIClientError, URL>
    func generate(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void>
}
