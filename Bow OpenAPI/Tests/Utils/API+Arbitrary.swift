//  Copyright © 2019 The Bow Authors.

import Foundation
import SwiftCheck

extension API.ContentType: Arbitrary {
    public static var arbitrary: Gen<API.ContentType> {
        let cases = API.ContentType.allCases
        return Gen.fromElements(of: cases)
    }
}
