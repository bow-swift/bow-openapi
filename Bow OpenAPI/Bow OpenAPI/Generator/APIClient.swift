//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

enum APIClient {
    static func bow(scheme: String, output: String) -> EnvIO<Environment, APIClientError, String> {
        EnvIO { env in
            let template = IO<APIClientError, String>.var()
            
            return binding(
                template <- getTemplatePath(),
                         |<-env.fileSystem.removeDirectory(output: output),
                         |<-env.fileSystem.createDirectory(output: output),
                         |<-env.generator.generate(scheme: scheme, output: output, template: template.get, logPath: env.logPath).provide(env.fileSystem),
            yield: "RENDER SUCCEEDED")^
        }
    }
    
    // MARK: attributes
    private static func getTemplatePath() -> IO<APIClientError, String> {
        guard let template = Bundle(path: "bow/openapi/templates")?.resourcePath else {
            return IO<APIClientError, String>.raiseError(APIClientError.templateNotFound)^
        }
        
        return IO<APIClientError, String>.pure(template)^
    }
}
