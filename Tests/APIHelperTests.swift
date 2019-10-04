//  Copyright © 2019 The Bow Authors.

import Foundation
import XCTest
import SwiftCheck


class APIHelperTests: XCTestCase {

    let allPresentGen = [String: QueryValue].arbitrary.map { dict in dict.mapValues { x in x as QueryValue? } }
    let nonePresentGen = [String: QueryValue?].arbitrary.map { dict in dict.mapValues { _ -> QueryValue? in nil } }
    
    func testQueryItems() {
        let args = CheckerArguments(replay: (StdGen(504558855, 9024), 2))
        property("Removes nil values", arguments: args) <- forAll(self.allPresentGen, self.nonePresentGen) { (present, absent) in
            let both: [String: Any?] = present.combine(absent).mapValues { $0 as Any? }
            let removed: [String: String] = both.mapValuesItems
            let expected = present.mapValues { $0 as Any? }.mapValuesItems
            
            return removed == expected
        }
        
        property("Query items remove invalid parameters") <- forAll { (queryItems: [String: QueryValue?]) in
            let itemsAny = queryItems.map { (key, query) in [key: query?.value] }.combineAll()
            let items = itemsAny.mapValuesItems
            
            return itemsAny.filter { (_, value) in value != nil }.count == items.count
        }
        
        property("Query items and URLQueryItem are isomorphic") <- forAll { (queryItems: [String: QueryValue?]) in
            let itemsAny = queryItems.map { (key, query) in [key: query?.value] }.combineAll()
            let items = itemsAny.mapValuesItems
            let queryItems = itemsAny.mapValuesToQueryItems ?? []
            let reverseItems = queryItems.map { query in [query.name: query.value] }.combineAll()
            
            return items == reverseItems
        }
    }
}
