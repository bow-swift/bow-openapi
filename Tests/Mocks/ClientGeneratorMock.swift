//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import OpenApiGenerator

class ClientGeneratorMock: ClientGenerator {
    private(set) var generateInvoked = false
    private let shouldFail: Bool
    
    init(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    func generate(module: OpenAPIModule) -> EnvIO<Environment, APIClientError, Void> {
        EnvIO { _ in
            self.generateInvoked = true
            let error = APIClientError(operation: "Testing", error: GeneratorError.structure)
            return self.shouldFail ? IO.raiseError(error): IO.pure(())^
        }
    }
    
    func getTemplates() -> EnvIO<Environment, APIClientError, URL> {
        EnvIO.pure(URL.templates)^
    }
}
