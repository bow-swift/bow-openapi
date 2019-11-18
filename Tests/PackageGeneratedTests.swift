//  Copyright © 2019 The Bow Authors.

import XCTest
import SnapshotTesting

class PackageGeneratedTests: XCTestCase {
    func testBuildProjectWithSwiftPackage() {
        assertSnapshot(matching: URL.schemas.file(.json), as: .generated(file: "Package.swift", module: "PetStore"))
    }
}
