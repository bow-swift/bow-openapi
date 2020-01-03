// nef:begin:header
/*
 layout: docs
 title: Testing your network calls
 */
// nef:end
// nef:begin:hidden
import Bow
import BowEffects

enum API {
    struct Config {
        let basePath: String
        
        func stub(json: String, code: Int = 200, endpoint: String = "") -> API.Config {
            self
        }
        
        func stub(error: Error, code: Int = 400, endpoint: String = "") -> API.Config {
            self
        }
    }
    
    enum HTTPError {}
}

struct Customer: Codable, Equatable {
    let identifier: Int
    let name: String
}

typealias Customers = [Customer]

protocol CustomerAPI {
    func getCustomers() -> EnvIO<API.Config, API.HTTPError, Customers>
}

struct CustomerAPIClient: CustomerAPI {
    func getCustomers() -> EnvIO<API.Config, API.HTTPError, Customers> {
        EnvIO.pure([])^
    }
}

extension API {
    var customer: CustomerAPI {
        CustomerAPIClient()
    }
}

func assert<T: Codable & Equatable>(_ envIO: EnvIO<API.Config, API.HTTPError, T>,
                                    withConfig: API.Config,
                                    succeeds: T,
                                    _ info: String) {}

// nef:end
/*:
 # Testing your network calls
 
 An important part of software development is testing. However, testing networking operations is usually cumbersome. It involves mocking dependencies in order to control the results of the network calls, and often we feel uncertain if we are actually testing our code or the mocks.
 
 Bow OpenAPI generates testing tools as part of its output, so that you can easily test your network calls behave as you expect, without actually going to the network. The tool produces a Swift Package that contains two libraries: one that contains the actual APIs described in the specification, and one with the same name and the suffix `Test` that provides some test utilities. For instance, assuming you invoke the tool as:
 
 ```bash
 $> bow-openapi --name SampleAPI --schema swagger.yaml --output ./Folder
 ```
 
 It will create a Swift Package with two modules: `SampleAPI` and `SampleAPITest`. In order to use the testing utilities, you would only need to import them:
 
 ```swift
 import SampleAPI
 import SampleAPITest
 ```
 
 In the following sections we will describe the utilities you have for testing.
 
 ## Stubbing responses
 
 In order to test our code, we need to control the scenarios that we want to test. When it comes to network calls, we usually need to stub the content we want in response of out requests.
 
 All this is done through the `API.Config` object. That means we do not need to modify our production code, but only provide a special configuration for testing. We can actually pass the same configuration that we use for production code, but with a small modification.
 
 Importing the testing module generated by Bow OpenAPI will add some extension methods on `API.Config` to let us stub content. The provided methods are:
 
 - `stub(data: Data)`: stubs a `Data` object in response to any network call.
 - `stub(error: Error)`: stubs an `Error` in response to any network call.
 - `stub(json: String)`: stubs a JSON formatted String in response to any network call.
 - `stub(contentsOfFile: URL)`: stubs the content of a file at a given `URL` in response to any network call.
 
 All these methods allow us to provide content in response to any network call, regardless of the endpoint that is being called. They also have an optional parameter `code`, where we can provide the HTTP response code that we want to receive (e.g. 404, 500, etc.).
 
 For instance, we can stub the response of some JSON content with code 200:
 */
let json = """
{
    "identifier": 1234,
    "name": "Tomás"
}
"""
let successConfig = API.Config(basePath: "https://url-to-my-server.com")
    .stub(json: json, code: 200)

/*:
 Or we can stub an error with a 404 code:
 */
enum CustomerError: Error {
    case notFound
}

let failureConfig = API.Config(basePath: "https://url-to-my-server.com")
    .stub(error: CustomerError.notFound, code: 404)
/*:
 Then, depending on the scenario you want to test, you only need use the right configuration:
 */
API.customer.getCustomers().provide(successConfig) // Tests the happy path
API.customer.getCustomers().provide(failureConfig) // Tests the unhappy path
/*:
 ## Stacking responses
 
 Stubs can be stacked in the `API.Config`, and they are removed as they are consumed. You can call several times to `stub` and those responses will be returned sequentially.
 
 If your code requires more responses than you have stubbed, you will get an error. Similarly, if you stub more content than you consume in the test, you should call `config.reset()` in order to clear the extra stubbed content.
 
 ## Routing responses
 
 If you are doing integration or end-to-end testing, your tests may perform several network calls in an order that you may not know beforehand. The testing tools provided in the module also let you stub content for a specific endpoint:
 */
let routingConfig = API.Config(basePath: "https://url-to-my-server.com")
    .stub(json: json, code: 200, endpoint: "/customers")
    .stub(json: "[]", code: 200, endpoint: "/products")
/*:
 ## Custom assertions
 
 Finally, the testing module provides custom assertions to test the success and failure scenarios. They are available as extension methods in `XCTest`. Therefore, you could write a test like:
 */
func testHappyPath() {
    let json = """
    {
        "identifier": 1234,
        "name": "Tomás"
    }
    """
    let successConfig = API.Config(basePath: "https://url-to-my-server.com")
        .stub(json: json, code: 200)
    let expected = [Customer(identifier: 1234, name: "Tomás")]
    
    assert(API.customer.getCustomers(),
           withConfig: successConfig,
           succeeds: expected,
           "Customer API did not return the expected result")
}
/*:
 Notice that Bow OpenAPI does not add conformance to `Equatable` in the generated code. Therefore, is up to the user to define when two value objects are equal by adding the corresponding extension.
 */
