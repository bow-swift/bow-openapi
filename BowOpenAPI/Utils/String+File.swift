//  Copyright © 2020 The Bow Authors.

import Foundation

extension String {
    var contentOfFile: String {
        let fileURL = URL(fileURLWithPath: expandingTildeInPath)
        let content = try? String(contentsOf: fileURL)
        return content ?? ""
    }
}
