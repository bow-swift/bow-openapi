//  Copyright © 2019 The Bow Authors.

import Foundation

public struct Environment {
    let logPath: String
    let fileSystem: FileSystem
    let generator: ClientGenerator
    
    public init(logPath: String, fileSystem: FileSystem, generator: ClientGenerator) {
        self.logPath = logPath
        self.fileSystem = fileSystem
        self.generator = generator
    }
}
