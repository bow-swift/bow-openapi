//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator


func main() {
    guard let arguments = CommandLine.input else { Console.help() }
    guard FileManager.default.fileExists(atPath: arguments.scheme) else { Console.exit(failure: "received invalid scheme path") }
    
    APIClient.bow(scheme: arguments.scheme, output: arguments.output)
             .provide(Environment(logPath: "/tmp/bow-openapi.log", fileSystem: MacFileSystem(), generator: SwaggerClientGenerator()))
             .unsafeRunSyncEither()
             .mapLeft { apiError in "could not generate api client for scheme '\(arguments.scheme)'\ninformation: \(apiError)" }
             .fold({ failure in Console.exit(failure: failure) },
                   { success in Console.exit(success: success) })
}

// #: - MAIN <launcher>
main()
