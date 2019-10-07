//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


class APIClientSendTests: XCTestCase {
    
    func testAPIClient_ValidRequestAndData_ShouldReceiveValidData() {
        let apiConfig = Mock.apiConfig.copy(decoder: StringUTF8Decoder())
                                      .stub(dataRaw: "data-success")
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               succeeds: "data-success")
    }

    func testAPIClient_ValidRequestAndInvalidData_ReturnError() {
        let apiConfig = Mock.apiConfig.stub(error: Mock.Error.general)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .otherError(Mock.Error.general))
    }

    func testAPIClient_ValidRequestAndInvalidDecoder_ReturnParsingError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success")

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .parsingError)
    }

    func testAPIClient_ValidRequestWithWrongDecoder_ReturnParsingError() {
        let apiConfig = Mock.apiConfig.copy(decoder: JSONDecoder()) // expected: StringUTF8Decoder()
                                      .stub(dataRaw: "data-success")

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .parsingError)
    }

    func testAPIClient_InvalidResponseWithCode400_ReturnBadRequest() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 400)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .badRequest)
    }

    func testAPIClient_InvalidResponseWithCode403_ReturnForbiddenError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 403)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .forbidden)
    }

    func testAPIClient_InvalidResponseWithCode404_ReturnNotFoundError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 404)

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .notFound)
    }

    func testAPIClient_InvalidResponseWithCode500_ReturnServerError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 500)
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .serverError)
    }

    func testAPIClient_InvalidResponseWithCode503_ReturnServiceUnavailable() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 503)
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .serviceUnavailable)
    }

    func testAPIClient_InvalidResponseWithUnknownCode_ReturnUnknownError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 69)
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               fails: .unknown)
    }

    func testAPIClient_EmptyJSONResponse_ReturnNoResponse() {
        let apiConfig = Mock.apiConfig.copy(decoder: JSONDecoder())
                                      .stub(dataRaw: "{}")
        
        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               succeeds: NoResponse())
    }

    func testAPIClient_EmptyStringResponse_ReturnNoResponse() {
        let apiConfig = Mock.apiConfig.copy(decoder: StringUTF8Decoder())
                                      .stub(dataRaw: "")

        assert(send(request: apiConfig.request),
               withConfig: apiConfig,
               succeeds: NoResponse())
    }
    
    // MARK: helpers for testing
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
