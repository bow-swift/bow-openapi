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


// MARK: - API.Helpers <generator>
enum QueryValue: Arbitrary, CaseIterable {
    case bool
    case float
    case int
    case int32
    case int64
    case double
    case string
    case array
    case dictionary
    case data
    case date
    case uuid
    
    static var arbitrary: Gen<QueryValue> {
        Gen<QueryValue>.fromElements(of: allCases)
    }
    
    private static var simpleArbitrary: Gen<QueryValue> {
        let simpleCases: [QueryValue] = [.bool, .float, .int, .int32, .int64, .double, .string, .data, .date, .uuid]
        return Gen<QueryValue>.fromElements(of: simpleCases)
    }
    
    var value: Any {
        switch self {
        case .bool:     return Bool.arbitrary.generate.encodeToJSON()
        case .float:    return Float.arbitrary.generate.encodeToJSON()
        case .int:      return Int.arbitrary.generate.encodeToJSON()
        case .int32:    return Int32.arbitrary.generate.encodeToJSON()
        case .int64:    return Int64.arbitrary.generate.encodeToJSON()
        case .double:   return Double.arbitrary.generate.encodeToJSON()
        case .string:   return String.arbitrary.generate.encodeToJSON()
        case .data:     return String.arbitrary.generate.data(using: .utf8)!.encodeToJSON()
        case .date:     return Date(timeIntervalSinceNow: TimeInterval.arbitrary.generate).encodeToJSON()
        case .uuid:     return UUID().uuidString.encodeToJSON()
            
        case .dictionary:
            return (0...UInt.arbitrary.generate+1).map { _ in
                [String.arbitrary.generate: QueryValue.simpleArbitrary.generate.value]
            }.combineAll().encodeToJSON()
            
        case .array:
            return (0...UInt.arbitrary.generate+1).map { _ in
                QueryValue.simpleArbitrary.generate.value
            }.encodeToJSON()
        }
    }
}


// MARK: Common <generator>
extension Data: Arbitrary {
    public static var arbitrary: Gen<Data> {
        let data = String.arbitrary.generate.data(using: .utf8)!
        return Gen<Data>.pure(data)
    }
}


extension ResponseDecoder {
    public static var arbitrary: Gen<Data> {
        fatalError()
    }
}
