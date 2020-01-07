// nef:begin:header
/*
 layout: docs
 title: Limitations
 */
// nef:end
/*:
 # Limitations
 
 Bow OpenAPI is very powerful and generates a ready to use network client in Swift that is as good as the specification you provide. If the specification is poor or flaky, the generated code will have the same problems. Generating code according to this specification is a way of honoring it, but it is important that this contract is also honored by the backend side.
 
 Nevertheless, Bow OpenAPI has some other limitations.
 
 ## Inline data types
 
 In order to have a proper generation, you need to define data models in the `components` section in OpenAPI, or in the `definitions` section in Swagger. Defining your data models inline can result in generated code that is not properly named and therefore difficult to use. Nested data type definition is not supported either; you will need to extract those types to the root of the definition of your models.
 
 ## Error data
 
 If you are specifying data models as part of the error response of an endpoint, Bow OpenAPI will not parse that into a value object. However, you will be able to access such information as it is carried in the `API.HTTPError` value that you will get.
 
 ## Body parameters encoding
 
 Currently, the only supported encoding for body parameters is `application/json`.
 */
