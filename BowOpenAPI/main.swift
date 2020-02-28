//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator

let prodEnv = Environment(logPath: "/tmp/bow-openapi.log",
                          fileSystem: MacFileSystem(),
                          generator: SwaggerClientGenerator())

extension BowOpenAPICommand {
    func run() throws {
        guard FileManager.default.fileExists(atPath: schema) else {
            Console.exit(failure: "received invalid schema path")
        }
        
        APIClient.bow(moduleName: name, scheme: schema, output: output)
            .provide(prodEnv)
            .unsafeRunSyncEither()
            .mapLeft { apiError in "could not generate api client for schema '\(schema)'\ninformation: \(apiError)" }
            .fold(Console.exit(failure:), Console.exit(success:))
    }
}

BowOpenAPICommand.main()
