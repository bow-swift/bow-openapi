//  Copyright © 2019 The Bow Authors.

import Foundation

class APITestCase {
    
    private let apiConfig: API.Config
    
    init(apiConfig: API.Config) {
        self.apiConfig = apiConfig
    }
    
    // MARK: send operation
    func send<T: Codable>(request: URLRequest) -> Either<API.HTTPError, T> {
        let envIO = EnvIO<API.Config, API.HTTPError, T> { config in
            API.send(request: request, session: config.session, decoder: config.decoder)
        }
            
        return envIO.provide(self.apiConfig).unsafeRunSyncEither()
    }
}
