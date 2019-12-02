---
layout: docs
title: Home
permalink: /docs/
---

# Bow Open API

Bow Open API is a command line tool to generate a network client written in Swift from an Open API specification that uses the environmental effect type `EnvIO` from [Bow](https://bow-swift.io/). Its main features are:

## Parsing of Open API specifications

Bow Open API is able to consume Open API / Swagger specifications as either JSON or YAML files. It relies on the `swagger-codegen` command line tool to parse these files, and then provides a set of templates to customize the output of the tool, together with an additional processing of the result.

## Pure functional Swift code

The generated code is written in Swift using the Bow Effects module, resulting in a 100% functional API. It uses `URLSession` under the hood to perform the network requests.

## Compatible with Swift Package Manager

The output of the tool is a Swift package that can be consumed using the Swift Package Manager. You can drag and drop it onto your Xcode project, or provide it to third parties just with your repository link.

## Testability

Besides the main module, the package includes a module for testing that enable seamless testing of your API calls, with stubbing of responses and errors, and easy assertions of the outputs. 
