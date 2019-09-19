//  Copyright © 2019 The Bow Authors.

import Foundation

func main() {
    guard let arguments = CommandLine.input else { Console.help() }
    guard FileManager.default.fileExists(atPath: arguments.scheme) else { Console.exit(failure: "received invalid scheme path") }
    guard APIClient.bow(scheme: arguments.scheme, output: arguments.output) else { Console.exit(failure: "could not generate api client for scheme \(arguments.scheme)") }
    
    Console.exit(success: "RENDER SUCCEEDED")
}

// #: - MAIN <launcher>
main()
