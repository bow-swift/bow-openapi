//  Copyright © 2020 The Bow Authors.

import Foundation
import Bow
import BowEffects

extension IO where E == FileSystemError {
    func toAPIClientEnv<D>() -> EnvIO<D, APIClientError, A> {
        mapError(FileSystemError.toAPIClientError).env()
    }
}
