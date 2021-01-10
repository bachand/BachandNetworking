//  Created by Michael Bachand on 8/21/20.

import XCTest

@testable import BachandNetworking

// MARK: - HTTPResponseTests

final class HTTPResponseTests: XCTestCase {

  // MARK: Internal

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

  // MARK: Private

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
}

// MARK: - HTTPResponseFactoryTests

final class HTTPResponseFactoryTests: XCTestCase {

  func test_makeSecureHTTPResponsePublisherForURL_schemeIsHTTPS_doesNotThrowsError() throws {
    try safelyUnwrapURL(string: "https://apple.com") { url in
      XCTAssertNoThrow(try makeSecureHTTPResponsePublisher(for: url))
    }
  }

  func test_makeSecureHTTPResponsePublisherForURL_schemeIsHTTP_throwsError() throws {
    try safelyUnwrapURL(string: "http://apple.com") { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotHTTPS.rawValue)
      }
      XCTAssertThrowsError(
        try makeSecureHTTPResponsePublisher(for: url),
        "Error has code for .schemeNotHTTPS",
        errorHandler)
    }
  }

  func test_makeSecureHTTPResponsePublisherForURL_schemeIsFTP_throwsError() throws {
    try safelyUnwrapURL(string: "ftp://apple.com") { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotHTTPS.rawValue)
      }
      XCTAssertThrowsError(
        try makeSecureHTTPResponsePublisher(for: url),
        "Error has code for .schemeNotHTTPS",
        errorHandler)
    }
  }

  func test_makeHTTPResponsePublisherForURL_schemeIsHTTP_doesNotThrowsError() throws {
    try safelyUnwrapURL(string: "http://apple.com") { url in
      XCTAssertNoThrow(try makeHTTPResponsePublisher(for: url))
    }
  }

  func test_makeHTTPResponsePublisherForURL_schemeIsHTTPS_doesNotThrowsError() throws {
    try safelyUnwrapURL(string: "https://apple.com") { url in
      XCTAssertNoThrow(try makeHTTPResponsePublisher(for: url))
    }
  }

  func test_makeHTTPResponsePublisherForURL_schemeIsFTP_throwsError() throws {
    try safelyUnwrapURL(string: "ftp://apple.com") { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotHTTPBased.rawValue)
      }
      XCTAssertThrowsError(
        try makeHTTPResponsePublisher(for: url),
        "Error has code for .schemeNotHTTPBased",
        errorHandler)
    }
  }

  func test_makeSecureHTTPResponsePublisherForURLRequest_schemeIsHTTPS_doesNotThrowsError() throws {
    try safelyUnwrapURL(string: "https://apple.com") { url in
      XCTAssertNoThrow(try makeSecureHTTPResponsePublisher(for: URLRequest(url: url)))
    }
  }

  func test_makeSecureHTTPResponsePublisherForURLRequest_schemeIsHTTP_throwsError() throws {
    try safelyUnwrapURL(string: "http://apple.com") { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotHTTPS.rawValue)
      }
      XCTAssertThrowsError(
        try makeSecureHTTPResponsePublisher(for: URLRequest(url: url)),
        "Error has code for .schemeNotHTTPS",
        errorHandler)
    }
  }

  func test_makeSecureHTTPResponsePublisherForURLRequest_schemeIsFTP_throwsError() throws {
    try safelyUnwrapURL(string: "ftp://apple.com") { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotHTTPS.rawValue)
      }
      XCTAssertThrowsError(
        try makeSecureHTTPResponsePublisher(for: URLRequest(url: url)),
        "Error has code for .schemeNotHTTPS",
        errorHandler)
    }
  }

  func test_makeSecureHTTPResponsePublisherForURLRequest_urlIsNil_throwsError() throws {
    try safelyUnwrapURL(string: "url/that/will/be/removed") { url in
      var urlRequest = URLRequest(url: url)
      urlRequest.url = nil
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.requestHasNoURL.rawValue)
      }
      XCTAssertThrowsError(
        try makeSecureHTTPResponsePublisher(for: urlRequest),
        "Error has code for .requestHasNoURL",
        errorHandler)
    }
  }

  func test_makeHTTPResponsePublisherForURLRequest_schemeIsHTTP_doesNotThrowsError() throws {
    try safelyUnwrapURL(string: "http://apple.com") { url in
      XCTAssertNoThrow(try makeHTTPResponsePublisher(for: URLRequest(url: url)))
    }
  }

  func test_makeHTTPResponsePublisherForURLRequest_schemeIsHTTPS_doesNotThrowsError() throws {
    try safelyUnwrapURL(string: "https://apple.com") { url in
      XCTAssertNoThrow(try makeHTTPResponsePublisher(for: URLRequest(url: url)))
    }
  }

  func test_makeHTTPResponsePublisherForURLRequest_schemeIsFTP_throwsError() throws {
    try safelyUnwrapURL(string: "ftp://apple.com") { url in
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.schemeNotHTTPBased.rawValue)
      }
      XCTAssertThrowsError(
        try makeHTTPResponsePublisher(for: URLRequest(url: url)),
        "Error has code for .schemeNotHTTPBased",
        errorHandler)
    }
  }

  func test_makeHTTPResponsePublisherForURLRequest_urlIsNil_throwsError() throws {
    try safelyUnwrapURL(string: "url/that/will/be/removed") { url in
      var urlRequest = URLRequest(url: url)
      urlRequest.url = nil
      let errorHandler: (Error) -> Void = {
        let nsError = $0 as NSError
        XCTAssertEqual(nsError.code, HTTPResponseError.Code.requestHasNoURL.rawValue)
      }
      XCTAssertThrowsError(
        try makeHTTPResponsePublisher(for: urlRequest),
        "Error has code for .requestHasNoURL",
        errorHandler)
    }
  }

  /// Attempts to create a URL from a string representing a URL, invoking the provided closure if the URL is non-`nil`. Fires an
  /// XCTest assertion on the calling line of code if the string does not represent a valid URL.
  private func safelyUnwrapURL(
    string: String,
    file: StaticString = #filePath,
    line: UInt = #line,
    runWithUnwrapped: (URL) throws -> Void) rethrows
  {
    let url = URL(string: string)
    let mappedURL: URL? = try url.flatMap { unwrappedURL in
      try runWithUnwrapped(unwrappedURL)
      return unwrappedURL
    }
    XCTAssertNotNil(
      mappedURL,
      "String \"\(string)\" must represent a valid URL",
      file: file,
      line: line)
  }
}
