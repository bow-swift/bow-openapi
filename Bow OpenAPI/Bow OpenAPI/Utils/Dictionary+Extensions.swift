//  Copyright © 2019 The Bow Authors.

import Foundation

extension Dictionary {
    
    func combine(_ other: [Key: Value]) -> [Key: Value] {
        var result = self
        for (key, value) in other {
            result[key] = value
        }
        return result
    }
}
