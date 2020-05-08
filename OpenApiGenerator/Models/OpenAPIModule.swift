//  Copyright © 2020 The Bow Authors.

import Foundation

public struct OpenAPIModule {
    let name: String
    let url: URL
    let schema: URL
    let templates: URL
    var sources: URL
    var tests: URL
    
    public init(name: String, url: URL, schema: URL, templates: URL) {
        let output = url.appendingPathComponent(name)
        
        self.name = name
        self.url = output
        self.schema = schema
        self.templates = templates
        self.sources = output.appendingPathComponent("Sources")
        self.tests = output.appendingPathComponent("XCTest")
    }
}
