//  Copyright © 2019 The Bow Authors.

import Foundation


/// Get paths for testing
extension URL {
    private static var tests: URL { URL(fileURLWithPath: String(#file)).deletingLastPathComponent().deletingLastPathComponent() }
    private static var xcproj: URL { URL(fileURLWithPath: String(#file)).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent() }
    
    static func temp(subfolder: String) -> URL { FileManager.default.temporaryDirectory.appendingPathComponent(subfolder) }
    static func currentFile(_ file: StaticString = #file) -> URL { URL(fileURLWithPath: "\(file)") }
    static let schemes = URL.tests.appendingPathComponent("__Snapshots__").appendingPathComponent("Schemes")
    static let templates = URL.xcproj.appendingPathComponent("Templates")
}

/// Concat to url path
extension URL {
    enum File: String {
        case noDefinedTags = "scheme-no-tags.yaml"
        case tags = "scheme-tags.yaml"
        case noDefinedOperationId = "scheme-no-operationid.yaml"
        case pathParam = "scheme-path-param.yaml"
        case queryParam = "scheme-query-param.yaml"
        case headerParam = "scheme-header-param.yaml"
        case bodyParam = "scheme-body-param.yaml"
    }
    
    func file(_ file: File) -> URL { appendingPathComponent(file.rawValue) }
}
