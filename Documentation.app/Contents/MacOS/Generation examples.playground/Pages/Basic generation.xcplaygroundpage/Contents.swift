// nef:begin:header
/*
 layout: docs
 title: Basic generation
 */
// nef:end
/*:
 # Basic generation
 
 Bow OpenAPI generates network clients from YAML and JSON descriptions in OpenAPI format. The simplest description we can make for an endpoint is:
 
 **YAML description**:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: Ping Service
   version: "1.2.3"
 paths:
   /ping:
     get:
       operationId: doPing
       responses:
         '204':
           description: Success
 ```
 
 **JSON description**:
 
 ```json
 {
   "openapi": "3.0.0",
   "info": {
     "title": "Ping Service",
     "version": "1.2.3"
   },
   "paths": {
     "/ping": {
       "get": {
         "operationId": "doPing",
         "responses": {
           "204": {
             "description": "Success"
           }
         }
       }
     }
   }
 }
 ```
 
 Both descriptions are equivalent and describe a single endpoint in a server, located under the path `/ping`, which responds to `GET` requests. The `operationId` corresponds to the name of the method that the tool will generate to invoke that operation. The endpoint always returns a `204` code, with no content.
 
 If we generate a network client from this specification, what we get is a protocol named `DefaultAPI` with a single method named `doPing`. This method returns a value of type `EnvIO<API.Config, API.HTTPError, NoResponse>`, where each type parameter means:
 
 - `API.Config` is a configuration object that contains information like the base URL or the headers for the request. This configuration needs to be provided to the `EnvIO` object befor running it. Notice that the `EnvIO` object *describes* the network request, but does not actually run it; it is suspended.
 - `API.HTTPError` is a description of the error that may happen when the network call happens.
 - `NoResponse` is a type describing the operation does not return any value.
 
 The first two type parameters will not change, whereas the last one will correspond to the type returned by the network call.
 
 The generation tool will provide an implementation of the `DefaultAPI` protocol and each of its methods, which we can access as:
 
 ```swift
 let result: EnvIO<API.Config, API.HTTPError, NoResponse> = API.default.doPing()
 ```
 
 ## Other methods
 
 The specification above describes a `GET` method, but we can provide descriptions of other methods, like `POST`, `PUT` or `DELETE`, even to the same path. They will be distinguished by their `operationId`:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: Ping Service
   version: "1.0.0"
 paths:
   /ping:
     get:
       operationId: getPing
       responses:
         '204':
           description: Success
     post:
       operationId: postPing
       responses:
         '204':
           description: Success
 ```
 
 This will generate two methods inside the `DefaultAPI` protocol named `getPing` and `postPing`, that will invoke the `GET` and `POST` methods of the `/ping` path, respectively.
 
 ```swift
 let get: EnvIO<API.Config, API.HTTPError, NoResponse> = API.default.getPing()
 let post: EnvIO<API.Config, API.HTTPError, NoResponse> = API.default.postPing()
 ```
 
 ## Using Swagger
 
 You can also provide your Swagger specification, and everything will work the same:
 
 ```yaml
 swagger: "2.0"
 info:
   title: Ping Service
   version: "1.2.3"
 paths:
   /ping:
     get:
       operationId: doPing
       responses:
         '204':
           description: Success
 ```
 */
