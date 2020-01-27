---
layout: docs
title: Customizing the configuration
permalink: /docs/consuming-generated-code/customizing-the-configuration/
---

# Customizing the configuration
 
 Before running any network request, we must provide an `API.Config` object. The minimum setup for this configuration includes a base path for all network requests:

```swift
let baseConfig = API.Config(basePath: "https://url-to-my-server.com")
```

 However, this can be customized in different ways to achieve our needs.
 
## Adding headers
 
 In some cases we may need to add headers to our requests. They can be added to a base configuration. Note that the original configuration will not be mutated, but a copy will be created with the new appended headers. We can use the following methods:

```swift
let configWithHeaders1 = baseConfig.appending(headers: ["Accept": "application/json"])
let configWithHeaders2 = baseConfig.appendingHeader(value: "application/json", forKey: "Accept")
let configWithHeaders3 = baseConfig.appending(contentType: .json)
```

 Besides this, all methods in our specification that require a header parameter will add an extension method to `API.Config`, where, if we provide a value, it will add it to the headers with the right key. For instance, if our methods require an authentication token, we may have a method like:

```swift
let authConfig = baseConfig.appendingHeader(token: "my-secure-token")
```

## Customizing URLSession
 
 By default, the configuration object uses `URLSession.shared`. However, you can create a configuration that uses your custom `URLSession` by passing an instance to the initializer:

```swift
let customSessionConfig = API.Config(basePath: "https://url-to-my-server.com",
                                     session: URLSession())
```

## Custom decoding
 
 The generated code uses `JSONDecoder` as a default decoder for the received responses. You can provide your own decoder if your server is sending responses in other formats. In such case, your decoder must implement a protocol named `ResponseDecoder` provided in the generated code.
 
 You may also need to provide a custom `JSONDecoder` depending on the date format that your backend is using. In such case, you can create the decoder:

```swift
let dateFormatter = DateFormatter()
dateFormatter.timeStyle = .medium
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .formatted(dateFormatter)
```

 And then pass it in the creation of the configuration object:

```swift
let customDecodingConfig = API.Config(basePath: "https://url-to-my-server.com",
                                      decoder: decoder)
```
