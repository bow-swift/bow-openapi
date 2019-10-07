//  Copyright © 2019 The Bow Authors.

import Foundation
import SwiftCheck

// MARK: - API.Config <generator>
extension API.ContentType: Arbitrary {
    public static var arbitrary: Gen<API.ContentType> {
        let cases = API.ContentType.allCases
        return Gen.fromElements(of: cases)
    }
}


// MARK: Common <generator>
extension Data: Arbitrary {
    public static var arbitrary: Gen<Data> {
        let data = String.arbitrary.generate.data(using: .utf8)!
        return Gen<Data>.pure(data)
    }
}

extension API.Config: Arbitrary {
    public static var arbitrary: Gen<API.Config> {
        String.arbitrary.map { path in
            API.Config.init(basePath: path, session: URLSession.shared, decoder: StringUTF8Decoder())
        }
    }
    
    public static var arbitraryWithHeaders: Gen<API.Config> {
        Gen.zip(API.Config.arbitrary, [String: String].arbitrary).map { config, headers in
            config.append(headers: headers)
        }
    }
}
