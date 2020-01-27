---
layout: docs
title: How to run Bow OpenAPI
permalink: /docs/quick-start/how-to-run-bow-openapi/
---

# How to run Bow OpenAPI
 
 Bow OpenAPI runs from your terminal with the following command:
 
 ```bash
 $> bow-openapi --name NetworkClient --schema API.json --output OutputFolder
 ```
 
 Where:
 
 - `--name`: Name of the resulting Swift package to be consumed from Swift Package Manager.
 - `--schema`: Path to a JSON or YAML file containing the OpenAPI / Swagger description of your endpoints.
 - `--output`: Path to the folder where the tool will write the generated files.
