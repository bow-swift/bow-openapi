---
layout: docs
title: Home
permalink: /docs/
---

# Bow OpenAPI

Bow OpenAPI is a command line tool to generate a network client written in Swift from an OpenAPI specification that uses the environmental effect type `EnvIO` from [Bow](https://bow-swift.io/). Its main features are:

💡 [Automatic generation](https://openapi.bow-swift.io/docs/generation-examples/basic-generation/) of network clients written in Swift from an OpenAPI / Swagger specification file, in YAML or JSON formats.

📦 Provision of a [Swift Package](https://openapi.bow-swift.io/docs/consuming-generated-code/adding-the-module-to-your-project/) that can be consumed from Swift Package Manager.

🔨 [Integration with Xcode](https://openapi.bow-swift.io/docs/quick-start/integration-in-xcode/) as a build phase to always keep your code in sync with your specification.

💥 Usage of [Environmental Effects](https://openapi.bow-swift.io/docs/consuming-generated-code/running-a-network-request/) from [Bow](https://bow-swift.io) to suspend side-effects, and improve their composition and testability.

✅ [Enhanced test support](https://openapi.bow-swift.io/docs/consuming-generated-code/testing-your-network-calls/) for integration or end-to-end test with no mocks.

## Parsing of OpenAPI specifications

Bow OpenAPI is able to consume OpenAPI / Swagger specifications as either JSON or YAML files. It relies on the `swagger-codegen` command line tool to parse these files, and then provides a set of templates to customize the output of the tool, together with an additional processing of the result.

## Pure functional Swift code

The generated code is written in Swift using the Bow Effects module, resulting in a 100% functional API. It uses `URLSession` under the hood to perform the network requests.

## Compatible with Swift Package Manager

The output of the tool is a Swift package that can be consumed using the Swift Package Manager. You can drag and drop it onto your Xcode project, or provide it to third parties just with your repository link.

## Testability

Besides the main module, the package includes a module for testing that enable seamless testing of your API calls, with stubbing of responses and errors, and easy assertions of the outputs. 
