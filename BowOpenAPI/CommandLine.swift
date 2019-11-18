//  Copyright © 2019 The Bow Authors.

import Foundation

let SCRIPT_NAME = "bow-openapi"

extension CommandLine {
    struct Arguments {
        let script: String
        let name: String
        let schema: String
        let output: String
    }
    
    static var input: Arguments? {
        guard CommandLine.arguments.count == 7,
              CommandLine.arguments[1] == "--name",
              CommandLine.arguments[3] == "--schema",
              CommandLine.arguments[5] == "--output" else { return nil }
        
        let scriptName = CommandLine.arguments.first?.components(separatedBy: "/").last ?? SCRIPT_NAME
        return Arguments(script: scriptName,
                         name: CommandLine.arguments[2],
                         schema: CommandLine.arguments[4].expandingTildeInPath,
                         output: CommandLine.arguments[6].expandingTildeInPath)
    }
}
