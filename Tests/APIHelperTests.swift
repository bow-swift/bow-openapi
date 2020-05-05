//  Copyright © 2019 The Bow Authors.

import XCTest
import SwiftCheck
@testable import FixturesAPI


class APIHelperTests: XCTestCase {
    let allPresentGen = [String: String].arbitrary.suchThat { $0.first?.key.isEmpty == false }
                                                  .map { $0 as [String: String?] }
    let nonePresentGen = [String: String?].arbitrary.suchThat { $0.first?.key.isEmpty == false  }
                                                    .map { dict in dict.mapValues { _ -> String? in nil } }
    
    func testQueryItems() {
        property("encodingValues remove nil values") <- forAll(self.allPresentGen, self.nonePresentGen) { (present, absent) in
            let both: [String: Any?] = present.combine(absent).any
            let removed: [String: String]  = both.encodingValues
            let expected: [String: String] = present.any.encodingValues

            return removed == expected
        }
        
        property("toQueryItems remove nil values") <- forAll(self.allPresentGen, self.nonePresentGen) { (present, absent) in
            let both: [String: Any?] = present.combine(absent).any
            let removed: [URLQueryItem]  = Array(Set(both.toQueryItems ?? [])).sorted { $0.name > $1.name }
            let expected: [URLQueryItem] = Array(Set(present.any.toQueryItems ?? [])).sorted { $0.name > $1.name }
            
            return expected == removed
        }
        
        property("Only items with nil values generate an empty URLQueryItem") <- forAll(self.nonePresentGen) { (absent) in
            absent.any.toQueryItems == nil
        }
        
        property("Items with no nil values generate valid URLQueryItems") <- forAll(self.allPresentGen) { (present) in
            (present.any.toQueryItems?.count ?? 0) == present.count
        }
    }
}

// MARK: helpers
fileprivate extension Dictionary {
    var any: [Key: Any?] { mapValues { x in x as Any? } }
}
