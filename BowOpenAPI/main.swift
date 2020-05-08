//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator
import Bow
import BowEffects

let prodEnv = Environment(logPath: "/tmp/bow-openapi.log",
                          fileSystem: MacFileSystem(),
                          generator: SwaggerClientGenerator())

extension BowOpenAPICommand {
    func run() throws {
        try run().provide(prodEnv).unsafeRunSync()
    }

    func run() -> EnvIO<Environment, APIClientError, Void> {
        APIClient.bow(moduleName: name, schema: schema, output: output)
            .reportStatus(
                { apiError in
                    """
                    Could not generate API client:
                    • SCHEMA '\(self.schema)'
                    \(apiError)
                    
                    \(self.verbose ?
                    "• LOG \n\n\(prodEnv.logPath.contentOfFile)\n" :
                    "• LOG: \(prodEnv.logPath)")
                    """
                },
                { success in
                    "\(success)"
                }
            ).finish()
    }
}

BowOpenAPICommand.main()
