//  Created by Michael Bachand on 8/21/20.

import XCTest

@testable import BachandNetworking

final class HTTPResponseTests: XCTestCase {

  func test_init_urlResponseIsNotHTTP_throwsError() {
    let errorHandler: (Error) -> Void = {
      let nsError = $0 as NSError
      XCTAssertEqual(nsError.code, HTTPResponseError.Code.responseNotHTTP.rawValue)
    }
    XCTAssertThrowsError(
      try HTTPResponse(data: .init(), urlResponse: URLResponse()),
      "Error has code for .responseNotHTTP",
      errorHandler)
  }

  func test_init_urlResponseIsHTTP_doesNotThrowError() {
    XCTAssertNoThrow(try HTTPResponse(data: .init(), urlResponse: HTTPURLResponse()))
  }

  func test_statusCode_returnsValueInURLResponse() throws {
    let urlResponse = makeStubHTTPURLResponse(statusCode: 10)
    let sut = try HTTPResponse(data: .init(), urlResponse: urlResponse)
    XCTAssertEqual(sut.statusCode, 10)
  }
}

final class HTTPResponseFactoryTests: XCTestCase {

  func test_schemeIsNotSecure_throwsError() throws {
    let url = URL(string: "http://apple.com")
    XCTAssertNotNil(try url.flatMap { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotSecure.rawValue)
      }
      XCTAssertThrowsError(
        try makeSecureDataTaskPublisher(for: url),
        "Error has code for .schemeNotSecure",
        errorHandler)
      return url
    })
  }
}

private func makeStubHTTPURLResponse(
  url: URL = URL(string: "/resource")!,
  statusCode: Int)
  -> HTTPURLResponse
{
  HTTPURLResponse(
    url: url,
    statusCode: statusCode,
    httpVersion: nil,
    headerFields: nil)!
}
