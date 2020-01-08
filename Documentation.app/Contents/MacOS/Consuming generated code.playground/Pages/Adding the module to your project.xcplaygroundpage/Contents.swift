// nef:begin:header
/*
 layout: docs
 title: Adding the module to your project
 */
// nef:end
/*:
 # Adding the module to your project
 
 After generating a network client using Bow OpenAPI, you will get a folder that contains all files together with the Swift Package manifest that describes the provided artifacts. Adding it to your Xcode Project is as easy as dragging the folder to the left panel in Xcode, and Xcode will automatically trigger the Swift Package Manager to download the dependencies.
 
 ![](/assets/project-tree.png)
 
 Then, you need to add the dependency to the target where you want to use the generated code:
 
 ![](/assets/add-frameworks.png)
 
 Finally, you can import it in your Swift files as:
 
 ```swift
 import SampleAPI
 ```
 */
