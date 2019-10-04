//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects


public enum Mock { }

extension Mock {
    static let apiConfig = API.Config(basePath: "http://www.google.es")
}

extension Mock {
    public enum URLRequestProvider {
        static var `default`: URLRequest { URLRequest(url: URL(string: "http://www.google.es")!) }
    }
}

extension Mock {
    public enum Error {
        static let general = MockError()
        static let invalid = InvalidDecoder.Exception.invalid
        static let incompatibleRequest = NSError(domain: "NSURLErrorDomain", code: -1002, userInfo: nil)
    }
}

extension Mock {
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
        IO.raiseError(DecodingError.other(Mock.Error.invalid))^
    }
}
