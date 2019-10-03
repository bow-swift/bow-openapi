//  Copyright © 2019 The Bow Authors.

import Foundation
import XCTest
import Bow
import BowEffects


class APIClientSendTests: APITestCase {
    
    func testAPIClient_ValidRequestAndData_ShouldReceiveValidData() {
        stub(dataRaw: "data-success")
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        assertSuccess(response: response, expected: "data-success")
    }

    func testAPIClient_ValidRequestAndInvalidData_ReturnError() {
        stub(error: Mock.Error.general)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        assertFailure(response: response, expected: .other(error: Mock.Error.general))
    }

    func testAPIClient_ValidRequestAndInvalidDecoder_ReturnParsingError() {
        stub(dataRaw: "data-success", decoder: Mock.Decoder.invalid)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .parsingError(response: dataError.response, data: dataError.data))
    }

    func testAPIClient_ValidRequestWithWrongDecoder_ReturnParsingError() {
        let decoder = JSONDecoder() // expected: StringUTF8Decoder()
        stub(dataRaw: "data-success", decoder: decoder)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .parsingError(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_InvalidRequest_ReturnLeftOtherError() {
        stub(dataRaw: "data-success")
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.invalid, session: .shared)
        
        assertFailure(response: response, expected: .other(error: Mock.Error.incompatibleRequest))
    }
    
    func testAPIClient_InvalidResponseWithCode400_ReturnBadRequest() {
        stub(dataRaw: "data-success", code: 400)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .badRequest(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_InvalidResponseWithCode403_ReturnForbiddenError() {
        stub(dataRaw: "data-success", code: 403)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .forbidden(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_InvalidResponseWithCode404_ReturnNotFoundError() {
        stub(dataRaw: "data-success", code: 404)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .notFound(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_InvalidResponseWithCode500_ReturnServerError() {
        stub(dataRaw: "data-success", code: 500)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .serverError(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_InvalidResponseWithCode503_ReturnServiceUnavailable() {
        stub(dataRaw: "data-success", code: 503)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .serviceUnavailable(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_InvalidResponseWithUnknownCode_ReturnUnknownError() {
        stub(dataRaw: "data-success", code: 69)
        let response: Either<API.HTTPError, String> = send(request: Mock.URLRequestProvider.default)
        
        let dataError = response.leftValue.dataError!
        assertFailure(response: response, expected: .unknown(response: dataError.response, data: dataError.data))
    }
    
    func testAPIClient_EmptyJSONResponse_ReturnNoResponse() {
        stub(dataRaw: "{}", decoder: JSONDecoder())
        let response: Either<API.HTTPError, NoResponse> = send(request: Mock.URLRequestProvider.default)
        
        assertSuccess(response: response, expected: NoResponse())
    }
    
    func testAPIClient_EmptyStringResponse_ReturnNoResponse() {
        stub(dataRaw: "", decoder: StringUTF8Decoder())
        let response: Either<API.HTTPError, NoResponse> = send(request: Mock.URLRequestProvider.default)
        
        assertSuccess(response: response, expected: NoResponse())
    }
}
