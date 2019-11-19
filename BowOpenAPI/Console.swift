//  Copyright © 2019 The Bow Authors.

import Foundation

enum Console {
    static func help() -> Never {
        print("\(SCRIPT_NAME) --name <name> --schema <schema json|yaml> --output <output path>")
        print("""

                    name: name for the output module.
                    schema: path to schema open api. ex. `/home/schema-openapi.json`
                    output: path where bow client will be generate. ex. `/home`

              """)
        Darwin.exit(0)
    }
    
    static func exit(failure: String) -> Never {
        print("☠️ error: \(failure)")
        Darwin.exit(-1)
    }
    
    static func exit(success: String) -> Never {
        print("🙌 success: \(success)")
        Darwin.exit(0)
    }
}
