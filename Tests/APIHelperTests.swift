//  Copyright © 2019 The Bow Authors.

import Foundation
import XCTest
import SwiftCheck


class APIHelperTests: XCTestCase {

    func testQueryItems() {
        property("Query items remove invalid parameters") <- forAll { (queryItems: [String: QueryValue?]) in
            let itemsAny = queryItems.map { (key, query) in [key: query?.value] }.combineAll()
            let items = API.Helper.mapValuesItems(itemsAny)
            
            return itemsAny.filter { (_, value) in value != nil }.count == items.count
        }
        
        property("Query items and URLQueryItem are isomorphic") <- forAll { (queryItems: [String: QueryValue?]) in
            let itemsAny = queryItems.map { (key, query) in [key: query?.value] }.combineAll()
            let items = API.Helper.mapValuesItems(itemsAny)
            let queryItems = API.Helper.mapValuesToQueryItems(itemsAny) ?? []
            let reverseItems = queryItems.map { query in [query.name: query.value] }.combineAll()
            
            return items == reverseItems
        }
    }
}
