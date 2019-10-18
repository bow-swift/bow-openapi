//  Copyright © 2019 The Bow Authors.

import Bow
import BowEffects

@testable import OpenApiGenerator


class ClientGeneratorMock: ClientGenerator {
    
    private(set) var generateInvoked = false
    private let shouldFail: Bool
    
    init(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    func generate(schemePath: String, outputPath: OutputPath, templatePath: String, logPath: String) -> EnvIO<FileSystem, APIClientError, ()> {
        EnvIO { _ in
            self.generateInvoked = true
            let error = APIClientError(operation: "Testing", error: GeneratorError.structure)
            return self.shouldFail ? IO.raiseError(error): IO.pure(())^
        }
    }
}
