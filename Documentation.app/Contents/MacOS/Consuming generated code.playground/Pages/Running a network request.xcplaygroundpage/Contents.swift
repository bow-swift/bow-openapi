// nef:begin:header
/*
 layout: docs
 title: Running a network request
 */
// nef:end
// nef:begin:hidden
import Bow
import BowEffects

enum API {
    struct Config {
        let basePath: String
    }
    
    enum HTTPError: Error {}
}

struct Customer {
    let identifier: Int
    let name: String
}

typealias Customers = [Customer]
// nef:end
/*:
# Running a network request

Bow OpenAPI groups network calls in small, concise protocols that can be accessed through the `API` object. Each generated method returns an `EnvIO<API.Config, API.HTTPError, A>` value, where `A` is the type of the returned value from the network call.
 
 This type represents a suspended computation that still needs a configuration object before running, and when provided so, it describes a computation that either produces an `HTTPError`, or a value of type `A`.
 
 For instance, considering the generated code provides a `CustomerAPI`:
*/
protocol CustomerAPI {
    func getCustomers() -> EnvIO<API.Config, API.HTTPError, Customers>
}
// nef:begin:hidden
struct CustomerAPIClient: CustomerAPI {
    func getCustomers() -> EnvIO<API.Config, API.HTTPError, Customers> {
        EnvIO { _ in
            IO.invoke {
                [ Customer(id: 1, name: "Tomás") ]
            }
        }
    }
}

extension API {
    var customer: CustomerAPI {
        CustomerAPIClient()
    }
}
// nef:end
/*:
 We can invoke this method as:
 */
let customersRequest = API.customer.getCustomers()
/*:
 However, this will not run the request. Here, `customersRequest` is just a description of the request that we can manipulate; we can handle potential errors, transform the output type, chain it with other requests and even run them in parallel. We recommend you to read the section for [Effects](https://bow-swift.io/next/docs/effects/overview/) in the documentation for Bow, for further information.
 
 We need to provide an API configuration to this request. To do so, we need a base path that will be used to append the paths to the requests described in the OpenAPI specification.
 */
let config = API.Config(basePath: "https://url-to-my-server.com")
customersRequest.provide(config)
/*:
 Finally, we can decide to run the request synchronously or asynchronously, and even change the dispatch queue where it will be executed:
 */

// Synchronous run
let customers: Customers? =
    try? customersRequest.provide(config).unsafeRunSync()

let either: Either<API.HTTPError, Customers> =
    customersRequest.provide(config).unsafeRunSyncEither()

// Asynchronous run
customersRequest.provide(config).unsafeRunAsync { either in
    either.fold({ httpError in /* ... */ },
                { customers in /* ... */ })
}

// Changing queue
let customers: Customers? = try? customersRequest.provide(config).unsafeRunSync(on: .background)
