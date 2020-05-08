//  Copyright © 2020 The Bow Authors.

import Foundation

public struct OpenAPIModule {
    let name: String
    let url: URL
    let schema: URL
    let templates: URL
    let sources: URL
    let tests: URL
    
    public init(name: String, url: URL, schema: URL, templates: URL) {
        self.init(name: name,
                  url: url,
                  schema: schema,
                  templates: templates,
                  sources: url.appendingPathComponent("Sources"),
                  tests: url.appendingPathComponent("XCTest"))
    }
    
    public init(name: String, url: URL, schema: URL, templates: URL, sources: URL, tests: URL) {
        self.name = name
        self.url = url.appendingPathComponent(name)
        self.schema = schema
        self.templates = templates
        self.sources = sources
        self.tests = tests
    }
}
