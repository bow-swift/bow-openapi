//  Copyright © 2019 The Bow Authors.

import ArgumentParser

struct BowOpenAPICommand: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "bow-openapi",
                                                    abstract: "Generate a Swift network client from an OpenAPI / Swagger specification file." )
    
    @Option(help: "The name for the output module.")
    var name: String
    
    @Option(help: "The path to schema open api. ex. `/home/schema-openapi.json`.")
    var schema: String
    
    @Option(help: "The path where bow client will be generate. ex. `/home`.")
    var output: String
}