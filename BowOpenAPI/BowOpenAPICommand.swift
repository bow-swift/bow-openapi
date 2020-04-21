//  Copyright © 2019 The Bow Authors.

import ArgumentParser

struct BowOpenAPICommand: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "bow-openapi",
                                                    abstract: "Generate a Swift network client from an OpenAPI / Swagger specification file." )
    
    @Option(help: "Name for the output module.")
    var name: String
    
    @Option(help: ArgumentHelp("Path to the OpenAPI/Swagger schema. ex. `/home/schema-openapi.json`.", valueName: "json|yaml"))
    var schema: String
    
    @Option(help: ArgumentHelp("Path where the Swift package containing the network client will be generated. ex. `/home`.", valueName: "output path"))
    var output: String
    
    @ArgumentParser.Flag (help: "Run in verbose mode")
    var verbose: Bool
}
