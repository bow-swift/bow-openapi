//  Copyright © 2019 The Bow Authors.

import XCTest
import Bow
import BowEffects


class APIClientSendTests: XCTestCase {
    
    func testAPIClient_ValidRequestAndData_ShouldReceiveValidData() {
        let apiConfig = Mock.apiConfig.copy(decoder: StringUTF8Decoder())
                                      .stub(dataRaw: "data-success")
        
        APITestCase(apiConfig: apiConfig)
            .send(request: apiConfig.request)
            .assert(success: "data-success")
    }

    func testAPIClient_ValidRequestAndInvalidData_ReturnError() {
        let apiConfig = Mock.apiConfig.stub(error: Mock.Error.general)
        
        APITestCase(apiConfig: apiConfig)
            .send(request: apiConfig.request)
            .map(Either<API.HTTPError, String>.pure)^
            .assert(error: .other(error: Mock.Error.general))
    }

    func testAPIClient_ValidRequestAndInvalidDecoder_ReturnParsingError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success")
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .parsingError(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_ValidRequestWithWrongDecoder_ReturnParsingError() {
        let apiConfig = Mock.apiConfig.copy(decoder: JSONDecoder()) // expected: StringUTF8Decoder()
                                      .stub(dataRaw: "data-success")
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .parsingError(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_InvalidResponseWithCode400_ReturnBadRequest() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 400)
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .badRequest(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_InvalidResponseWithCode403_ReturnForbiddenError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 403)
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .forbidden(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_InvalidResponseWithCode404_ReturnNotFoundError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 404)
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .notFound(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_InvalidResponseWithCode500_ReturnServerError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 500)
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .serverError(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_InvalidResponseWithCode503_ReturnServiceUnavailable() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 503)
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .serviceUnavailable(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_InvalidResponseWithUnknownCode_ReturnUnknownError() {
        let apiConfig = Mock.apiConfig.copy(decoder: Mock.Decoder.invalid)
                                      .stub(dataRaw: "data-success", code: 69)
        
        let response: Either<API.HTTPError, String> = APITestCase(apiConfig: apiConfig)
                                                            .send(request: apiConfig.request)
        
        let dataError = response.leftValue.dataError!
        response.assert(error: .unknown(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_EmptyJSONResponse_ReturnNoResponse() {
        let apiConfig = Mock.apiConfig.copy(decoder: JSONDecoder())
                                      .stub(dataRaw: "{}")
        
        APITestCase(apiConfig: apiConfig)
            .send(request: apiConfig.request)
            .assert(success: NoResponse())
    }

    func testAPIClient_EmptyStringResponse_ReturnNoResponse() {
        let apiConfig = Mock.apiConfig.copy(decoder: StringUTF8Decoder())
                                      .stub(dataRaw: "")
        
        APITestCase(apiConfig: apiConfig)
            .send(request: apiConfig.request)
            .assert(success: NoResponse())
    }
}
