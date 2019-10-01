//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow

extension Dictionary: Monoid {
    public static func empty() -> Dictionary<Key, Value> {
        return [:]
    }
    
    public func combine(_ other: [Key: Value]) -> [Key: Value] {
        var result = self
        for (key, value) in other {
            result[key] = value
        }
        return result
    }
}
