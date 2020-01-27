---
layout: docs
title: Integration in Xcode
permalink: /docs/quick-start/integration-in-xcode/
---

# Integration in Xcode
 
 Bow OpenAPI can be integrated in Xcode easily to regenerate your network client whenever the specification changes. Assuming you have already installed Bow OpenAPI in your computer, you can follow these steps.
 
## Add the specification file
 
 Add the OpenAPI/Swagger specification file to the root of your project, as depicted in the image.
 
 ![](/assets/spec-file.png)
 
## Create an Aggregate
 
 Add a new target to your project and select Aggregate, giving it the name you prefer.
 
 ![](/assets/aggregate.png)
 
## Run script
 
 Select your recently created Aggregate and go to its Build Phases tab. Add a New Run Script Phase. There, you can invoke the Bow OpenAPI command, passing the values you need for your project.
 
 ![](/assets/build-phase.png)
 
## Build
 
 From now on, if you run the scheme corresponding to this Aggregate, it will regenerate the network client based on the specification file. Drag the folder containing the generated code and drop it onto your project, and Swift Package Manager will start fetching your dependencies.
