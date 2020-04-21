//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects
import OpenApiGenerator

public extension Kleisli where F == IOPartial<APIClientError> {
    
    func reportStatus(
        _ failure: @escaping (APIClientError) -> String,
        _ success: @escaping (A) -> String)
        -> EnvIO<D, APIClientError, A> {
        
        self.foldM(
            { e in
                ConsoleIO.print("☠️ \(failure(e))").env().followedBy(.raiseError(e))^
            },
            { a in
                ConsoleIO.print("🙌 \(success(a))").env().followedBy(.pure(a))^
            }
        )^
    }
}

public extension Kleisli where F == IOPartial<APIClientError> {
    func finish() -> EnvIO<D, APIClientError, Void>  {
        self.foldM(
            { _ in
                EnvIO.invoke { _ in Darwin.exit(-1) }
            },
            { _ in
                EnvIO.invoke { _ in Darwin.exit(0) }
            })
    }
}
