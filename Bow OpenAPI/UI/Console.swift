//  Copyright © 2019 The Bow Authors.

import Foundation

enum Console {
    static func help() -> Never {
        print("\(SCRIPT_NAME) --scheme <scheme json|yaml> --output <output path>")
        print("""

                    scheme: path to scheme open api. ex. `/home/scheme-openapi.json`
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
