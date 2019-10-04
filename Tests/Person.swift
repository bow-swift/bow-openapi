import Foundation
import BowEffects

struct Person: Codable {
    let name: String
}

protocol PersonAPI {
    func getPerson() -> EnvIO<API.Config, API.HTTPError, Person>
}

struct PersonAPIClient: PersonAPI {
    func getPerson() -> EnvIO<API.Config, API.HTTPError, Person> {
        EnvIO { config in
            let request = URLRequest(url: URL(string: config.basePath)!)
            return API.send(request: request, session: config.session, decoder: config.decoder)
        }
    }
}
