// nef:begin:header
/*
 layout: docs
 title: Documentation
 */
// nef:end
/*:
 # Documentation
 
 Bow OpenAPI leverages the documentation added in the specification so that you have it available as inline docs in Xcode. For instance, consider the following example:
 
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
       description: Obtains all products sold by the store.
       parameters:
         - name: sortBy
           in: query
           required: true
           description: Sorting criteria.
           schema:
             $ref: '#/components/schemas/SortBy'
       responses:
         '200':
           description: All products in the store.
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/Products'
 ```
 
 The generator will take all the metadata in the fields named `description` and will use that information for documentation of the corresponding artifacts.
 */
