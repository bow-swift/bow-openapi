//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


class APIClientSendTests: XCTestCase {
    func testAPIClient_ValidRequestAndData_ShouldReceiveValidData() {
        let apiConfig = Mother.stringDecoderApiConfig
            .stub(dataRaw: "data-success")
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               succeeds: "data-success")
    }

    func testAPIClient_ValidRequestAndInvalidData_ReturnError() {
        let apiConfig = Mother.apiConfig.stub(error: Mother.Error.general)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .otherError(Mother.Error.general))
    }

    func testAPIClient_ValidRequestAndInvalidDecoder_ReturnParsingError() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success")

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .parsingError)
    }

    func testAPIClient_ValidRequestWithWrongDecoder_ReturnParsingError() {
        let apiConfig = Mother.jsonDecoderApiConfig // expected: StringUTF8Decoder()
            .stub(dataRaw: "data-success")

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .parsingError)
    }

    func testAPIClient_InvalidResponseWithCode400_ReturnBadRequest() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success", code: 400)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .badRequest)
    }

    func testAPIClient_InvalidResponseWithCode403_ReturnForbiddenError() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success", code: 403)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .forbidden)
    }

    func testAPIClient_InvalidResponseWithCode404_ReturnNotFoundError() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success", code: 404)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .notFound)
    }

    func testAPIClient_InvalidResponseWithCode500_ReturnServerError() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success", code: 500)
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .serverError)
    }

    func testAPIClient_InvalidResponseWithCode503_ReturnServiceUnavailable() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success", code: 503)
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .serviceUnavailable)
    }

    func testAPIClient_InvalidResponseWithUnknownCode_ReturnUnknownError() {
        let apiConfig = Mother.apiConfig.copy(decoder: Mother.Decoder.invalid)
            .stub(dataRaw: "data-success", code: 69)
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .unknown)
    }

    func testAPIClient_EmptyJSONResponse_ReturnNoResponse() {
        let apiConfig = Mother.jsonDecoderApiConfig
            .stub(dataRaw: "{}")
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               succeeds: NoResponse())
    }

    func testAPIClient_EmptyStringResponse_ReturnNoResponse() {
        let apiConfig = Mother.stringDecoderApiConfig
            .stub(dataRaw: "")

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               succeeds: NoResponse())
    }
    
    func testAPIClient_RoutingStubs() {
        let apiConfig = Mother.jsonDecoderApiConfig
            .stub(error: Mother.Error.general, endpoint: "/failing-endpoint")
            .stub(dataRaw: "{}", endpoint: "/test")
            
        let request = URLRequest(url: URL(string: apiConfig.basePath + "/test")!)
        
        assert(send(request: request),
               withConfig: apiConfig,
               succeeds: NoResponse())
    }
    
    func testAPIClient_StackingResponses() {
        let apiConfig = Mother.jsonDecoderApiConfig
            .stub(error: Mother.Error.general, endpoint: "/test")
            .stub(dataRaw: "{}", endpoint: "/test")
            
        let request = URLRequest(url: URL(string: apiConfig.basePath + "/test")!)
        
        assert(send(request: request),
               withConfig: apiConfig,
               fails: .otherError(Mother.Error.general))
        
        assert(send(request: request),
               withConfig: apiConfig,
               succeeds: NoResponse())
    }
    
    // MARK: Helpers for testing
    private func send<T: Codable>(request: URLRequest) -> EnvIO<API.Config, API.HTTPError, T> {
        EnvIO { apiConfig in
            API.send(request: request, session: apiConfig.session, decoder: apiConfig.decoder)
        }
    }

    private func send(request: URLRequest) -> EnvIO<API.Config, API.HTTPError, String> {
        EnvIO { apiConfig in
            API.send(request: request, session: apiConfig.session, decoder: apiConfig.decoder)
        }
    }
}


fileprivate extension API.Config {
    var request: URLRequest {
        return URLRequest(url: URL(string: basePath)!)
    }
}
