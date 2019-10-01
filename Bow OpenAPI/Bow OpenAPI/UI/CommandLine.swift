//  Copyright © 2019 The Bow Authors.

import Foundation

let SCRIPT_NAME = "bow-openapi"

extension CommandLine {
    struct Arguments {
        let script: String
        let scheme: String
        let output: String
    }
    
    static var input: Arguments? {
        guard CommandLine.arguments.count == 5,
              CommandLine.arguments[1] == "--scheme",
              CommandLine.arguments[3] == "--output" else { return nil }
        
        let scriptName = CommandLine.arguments.first?.components(separatedBy: "/").last ?? SCRIPT_NAME
        return Arguments(script: scriptName,
                         scheme: CommandLine.arguments[2].expandingTildeInPath,
                         output: CommandLine.arguments[4].expandingTildeInPath)
    }
}
