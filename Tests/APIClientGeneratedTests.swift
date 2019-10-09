//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting


class APIClientGeneratedTests: XCTestCase {
    
    func testPathParam() {
        assertSnapshot(matching: URL.schemes.file(.pathParam), as: .generated(file: "DefaultAPI.swift"))
    }
}
