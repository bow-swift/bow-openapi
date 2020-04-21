//  Copyright © 2019 The Bow Authors.

import Foundation

public struct Environment {
    public let logPath: String
    public let fileSystem: FileSystem
    public let generator: ClientGenerator
    
    public init(logPath: String, fileSystem: FileSystem, generator: ClientGenerator) {
        self.logPath = logPath
        self.fileSystem = fileSystem
        self.generator = generator
    }
}
