//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

public enum Mother { }

extension Mother {
    static let baseURL = "http://www.bow-swift.io"
    static let apiConfig = API.Config(basePath: baseURL)
}

extension Mother {
    public enum URLRequestProvider {
        static var `default`: URLRequest { URLRequest(url: URL(string: baseURL)!) }
    }
}

extension Mother {
    public enum Error {
        static let general = MockError()
        static let invalid = InvalidDecoder.Exception.invalid
        static let incompatibleRequest = NSError(domain: "NSURLErrorDomain", code: -1002, userInfo: nil)
    }
}

extension Mother {
    public enum Decoder {
        static let invalid = InvalidDecoder()
    }
}

// MARK: - Utilities <helpers>
class MockError: Error { }

class InvalidDecoder: ResponseDecoder {
    enum Exception: Error {
        case invalid
    }
    
    func safeDecode<T>(_ type: T.Type, from: Data) -> IO<DecodingError, T> where T : Decodable {
        IO.raiseError(DecodingError.other(Mother.Error.invalid))^
    }
}
