---
layout: docs
title: Grouping endpoints
permalink: /docs/generation-examples/grouping-endpoints/
---

# Grouping endpoints
 
 By default, all described endpoint will be included as methods of the generated `DefaultAPI`. However, this can become quite inconvenient quickly, as the number of methods in your OpenAPI specification increases.
 
 In order to avoid that, we can group methods semantically using the `tags` attribute from the OpenAPI specification. We can label each method with a tag, and they will be included in a protocol named after the tag.
 
 For instance, consider the following description for a store service:
 
 ```yaml
 openapi: "3.0.0"
 info:
   title: My Store
   version: "1.0.0"
 paths:
   /customers:
     get:
       tags:
         - Customer
       operationId: getCustomers
       responses:
         '200':
           description: All customers in the store
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/Customers'
   /products:
     get:
       tags:
         - Product
       operationId: getProducts
       responses:
         '200':
           description: All products in the store
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/Products'
 ```
 
 Since both methods have a tag, the `DefaultAPI` protocol will not be generated. Instead, protocols named `CustomerAPI` and `ProductAPI` will be created, containing the methods `getCustomers` and `getProducts`, respectively.
 
 As with the `DefaultAPI`, they can be invoked as:
 
 ```swift
 let customersRequest = API.customer.getCustomers()
 let productsRequest = API.product.getProducts()
 ```
 
 Adding the same tag to multiple methods will make them belong under the same protocol. This is usually a good practice in order to segregate the responsibilities of the network client and restrict the visibility of certain operations to some parts of your code.
