//  Copyright © 2019 The Bow Authors.

import Foundation

enum Console {
    static func exit(failure: String) -> Never {
        print("☠️ error: \(failure)")
        Darwin.exit(-1)
    }
    
    static func exit(success: String) -> Never {
        print("🙌 success: \(success)")
        Darwin.exit(0)
    }
}
