//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator

let prodEnv = Environment(logPath: "/tmp/bow-openapi.log",
                          fileSystem: MacFileSystem(),
                          generator: SwaggerClientGenerator())

func main() {
    guard let arguments = CommandLine.input else { Console.help() }
    guard FileManager.default.fileExists(atPath: arguments.schema) else { Console.exit(failure: "received invalid schema path") }
    
    APIClient.bow(scheme: arguments.schema, output: arguments.output)
             .provide(prodEnv)
             .unsafeRunSyncEither()
             .mapLeft { apiError in "could not generate api client for schema '\(arguments.schema)'\ninformation: \(apiError)" }
             .fold(Console.exit(failure:), Console.exit(success:))
}

// #: - MAIN <launcher>
main()
