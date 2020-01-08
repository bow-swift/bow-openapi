// nef:begin:header
/*
 layout: docs
 title: Parameters
 */
// nef:end
/*:
 # Parameters
 
 Network requests are usually parameterized. Clients must pass values in the network calls to get certain responses. These parameters can be included in different places in the network request: in the path, in the query parameters, in the request body or in the headers.
 
 ## Path parameters
 
 Path parameters are included in the path of the request. They are described in OpenAPI like:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
   /{category}/product:
     get:
       tags:
         - Product
       operationId: getProductsForCategory
       parameters:
         - name: category
           in: path
           required: true
           schema:
             type: string
       responses:
         '200':
           description: All products of a category
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/Products'
 ```
 
 Here, the parameter `category` is sent as part of the path of the request. When code is generated, it will be a parameter for the `getProductsForCategory` method, and the generated implementation will know where to encode it.
 
 ## Query parameters
 
 Query parameters are included after the path of the request, as a list of key-value pairs. They are described in OpenAPI like:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 paths:
   /products:
     get:
       tags:
         - Product
       operationId: getProducts
       parameters:
         - name: sortBy
           in: query
           required: true
           schema:
             $ref: ' #/components/schemas/SortBy'
       responses:
         '200':
           description: All products in the store
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/Products'
 ```
 
 The `sortBy` parameter is sent as a pair after the path of the request. When code is generated, it will be a parameter for the `getProducts` method, and the generated implementation will know where to encode it.
 
 ## Body parameters
 
 Body parameters are included in the body of a request. They are described in OpenAPI like:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 paths:
   /customers/new:
     post:
       tags:
         - Customer
       operationId: newCustomer
       requestBody:
         required: true
         content:
           application/json:
             schema:
               $ref: '#/components/schemas/Customer'
       responses:
         '204':
           description: Customer created
 ```
 
 This request requires a `Customer` to be sent as part of the body. The generated code will add a parameter to the `newCustomer` where a value of type `Customer` needs to be passed, and the generated implementation will know where to encode it. Currently, the only encoding that is supported is JSON.
 
 ## Header parameters
 
 Header parameters are sent as part of the headers of the request. They can be specified in OpenAPI like:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 paths:
   /customers/me:
     get:
       tags:
         - Customer
       operationId: getMyProfile
       parameters:
         - name: token
           in: header
           required: true
           schema:
             $ref: '#/components/schemas/Token'
       responses:
         '200':
           description: The profile of the logged in user
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/Customer'
 ```
 
 Header parameters are often used to send authentication information, as the `token` above. Unlike path, query or body parameters, header parameters are not included as part of the signature of the generated method. That is, the `getMyProfile` method generated from the description above will not have any parameters.
 
 In this case, header parameters are passed as part of the `API.Config`. Values for these headers can be added to the configuration using the appropriate generated methods.
 
 For instance, for the example above, `API.Config` will get an extension method named `appendingHeaders(token: Token)`, which will return a new configuration that will add the value we passed as a parameter, in the headers of the network requests that we perform with such configuration.
 */
