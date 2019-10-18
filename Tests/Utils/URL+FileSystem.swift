//  Copyright © 2019 The Bow Authors.

import Foundation


extension URL {
    
    func find(item: String) -> URL? {
        FileManager.default.enumerator(atPath: self.path)?
                           .compactMap { $0 as? String }
                           .first { _item in _item.filename == item }
                           .flatMap { relativePath in self.appendingPathComponent(relativePath) }
        
    }
}
