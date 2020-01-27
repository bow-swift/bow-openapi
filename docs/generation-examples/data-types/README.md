---
layout: docs
title: Data types
permalink: /docs/generation-examples/data-types/
---

# Data types
 
 The OpenAPI specification lets us describe the data types that we are using in our services. Bow OpenAPI uses this description to generate data types using value objects (structs).
 
 In order to have a proper generation, you need to define data models in the `components` section in OpenAPI, or in the `definitions` section in Swagger. Defining your data models inline can result in generated code that is not properly named and therefore difficult to use.
 
 For instance, consider the following specification:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 components:
   schemas:
     Customer:
       type: object
       required:
         - id
         - name
       properties:
         identifier:
           type: integer
         name:
           type: string
 ```
 
 This will generate a struct named `Customer` with two fields: `identifier` of type `Int` and `name` of type `String`. It will also have a generated initializer that is public outside the module.
 
 Generated data types will conform to `Codable`. If names of the properties are written using snake case, the generated code will convert them to camel case and handle the creation of the corresponding coding keys.
 
## Required and optional properties
 
 All fields in the example above are required; however, that may not always be the case. If we add another field to the model above to include a `photo_url` to `Customer`:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 components:
   schemas:
     Customer:
       type: object
       required:
         - id
         - name
       properties:
         identifier:
           type: integer
         name:
           type: string
         photo_url:
           type: string
 ```
 
 The generated type for the corresponding field will leverage Swift optionals and use `String?`. This is important; if the field is marked as required, but the server ever sends an absent value for that field, it will produce a decoding error, causing the request to fail.
 
## Arrays
 
 Some request can also return collections of objects of a complex data type that we have created. In such case, we can define our data type as an array that references the complex model that we have created:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 components:
   schemas:
     Customers:
       type: array
       items:
         $ref: '#/components/schemas/Customer'
 ```
 
 As a result, Bow OpenAPI will generate a type alias named `Customers`, which will represent `[Customer]`.
 
## Enumerations
 
 Some data types can only take values of a discrete set. For instance, the status of a product can be available or sold out:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 components:
   schemas:
     Status:
       type: string
       enum:
         - Available
         - SoldOut
 ```
 
 To handle that, Bow OpenAPI will generate an enum backed by Strings, containing only the specified cases in the description.
