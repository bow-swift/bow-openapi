//  Copyright © 2019 The Bow Authors.

import Foundation

public struct Environment {
    let log: URL
    let fileSystem: FileSystem
    let generator: ClientGenerator
    
    public init(log: URL, fileSystem: FileSystem, generator: ClientGenerator) {
        self.log = log
        self.fileSystem = fileSystem
        self.generator = generator
    }
}
