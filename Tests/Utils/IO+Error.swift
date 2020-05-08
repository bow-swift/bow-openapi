//  Copyright © 2020 The Bow Authors.

import Foundation
import Bow
import BowEffects

extension EnvIO where A == Void {
    func ignoreError<E: Swift.Error, EE: Error>() -> EnvIO<D, EE, Void> where F == IOPartial<E> {
        handleError { _ in }^.mapError { e in e as! EE }
    }
}

extension IO where A == Void {
    func ignoreError<EE: Error>() -> IO<EE, Void> {
        handleError { _ in }^.mapError { e in e as! EE }
    }
}
