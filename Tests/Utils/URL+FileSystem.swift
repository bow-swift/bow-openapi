//  Copyright © 2019 The Bow Authors.

import Foundation
import OpenApiGenerator
import Bow
import BowEffects

extension URL {
    
    func find(file: String) -> URL? {
        FileManager.default.enumerator(atPath: self.path)?
                           .compactMap { $0 as? String }
                           .first { item in item.filename == file }
                           .flatMap { relativePath in self.appendingPathComponent(relativePath) }
        
    }
}
