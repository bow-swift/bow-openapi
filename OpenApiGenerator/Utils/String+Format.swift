//  Copyright © 2019 The Bow Authors.

import Foundation

public typealias SubstringType = (output: String, range: NSRange)

public extension String {
    
    func substring(pattern: String) -> SubstringType? {
        let range = NSRange(location: 0, length: self.count)
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: self, options: [], range: range) else { return nil }

        let output = NSString(string: self).substring(with: match.range) as String
        return (output, match.range)
    }

    func clean(_ ocurrences: String...) -> String {
        ocurrences.reduce(self) { (output, ocurrence) in
            output.replacingOccurrences(of: ocurrence, with: "")
        }
    }

    var trimmingWhitespaces: String {
        trimmingCharacters(in: .whitespaces)
    }
    
    var trimmingNewLines: String {
        trimmingCharacters(in: .newlines)
    }
}
