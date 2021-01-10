//  Created by Michael Bachand on 8/21/20.

import Combine
import Foundation

/// A value type representing a HTTP response.
public struct HTTPResponse {
  /// - Throws: All errors are of type `NSError` and will have the domain "HTTPResponse". If `urlResponse` is any type other
  ///   than `HTTPURLResponse` the error code is 100.
  init(data: Data, urlResponse: URLResponse) throws {
    self.data = data
    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
      throw makeError(code: .responseNotHTTP)
    }
    self.response = httpURLResponse
  }

  /// The data returned.
  public let data: Data
  /// The underlying response object.
  public let response: HTTPURLResponse
  /// The HTTP status code of the response.
  public var statusCode: Int { response.statusCode }
}

/// A namespace for values associated with any error encountered during the process of getting a `HTTPResponse`.
enum HTTPResponseError {
  /// The domain of errors.
  public static let errorDomain = "HTTPResponse"

  /// An error code associated with `HTTPResponse`.
  enum Code: Int {
    /// Apple Foundation framework returns a response that is not of type `HTTPURLResponse`.
    case responseNotHTTP = 100
    /// Developer specified a URL that does not have the "https" scheme.
    case schemeNotHTTPS = 101
    /// Developer specified a URL that does not have a "http" or "https" scheme.
    case schemeNotHTTPBased = 102
    /// Developer specified a URL request with no associated URL.
    case requestHasNoURL = 103
  }
}

/// Creates a data task publisher for a URL where the data is retrievable over HTTP. The output of that publisher is mapped to a
/// `HTTPResponse`.
///
/// - Parameter url: The URL to which we should make a request.
/// - Parameter session: The session that will make the request.
///
/// - Returns: A type-erased publisher.
///
/// - Throws: All errors are of type `NSError` and will have the domain "HTTPResponse". If the URL has any scheme other than
///   "https" the error code is 101.
public func makeSecureHTTPResponsePublisher(
  for url: URL,
  on urlSession: URLSession = .shared)
  throws
  -> AnyPublisher<HTTPResponse, URLError>
{
  guard let scheme = url.scheme, scheme == "https" else { throw makeError(code: .schemeNotHTTPS) }
  return try makeHTTPResponsePublisher(for: url, on: urlSession)
}

/// Creates a data task publisher for a URL where the data is retrievable over HTTP or HTTPS. The output of that publisher is mapped to
/// a `HTTPResponse`.
///
/// - Parameter url: The URL to which we should make a request.
/// - Parameter session: The session that will make the request.
///
/// - Returns: A type-erased publisher.
///
/// - Throws: All errors are of type `NSError` and will have the domain "HTTPResponse". If the URL has any scheme other than
///   "http" or "https" the error code is 102.
public func makeHTTPResponsePublisher(
  for url: URL,
  on urlSession: URLSession = .shared)
  throws
  -> AnyPublisher<HTTPResponse, URLError>
{
  guard let scheme = url.scheme, ["http", "https"].contains(scheme) else {
    throw makeError(code: .schemeNotHTTPBased)
  }

  return urlSession.dataTaskPublisher(for: url).eraseToAnyPublisherOfHTTPResponse()
}

/// Creates a data task publisher for a URL request where the data is retrievable over HTTP. The output of that publisher is mapped to a
/// `HTTPResponse`.
///
/// - Parameter urlRequest: The URL request to be made.
/// - Parameter session: The session that will make the request.
///
/// - Returns: A type-erased publisher.
///
/// - Throws: All errors are of type `NSError` and will have the domain "HTTPResponse". If the request's URL has any scheme
///   other than "https" the error code is 101. If the request does not have a URL the error code is 103.
public func makeSecureHTTPResponsePublisher(
  for urlRequest: URLRequest,
  on urlSession: URLSession = .shared)
  throws
  -> AnyPublisher<HTTPResponse, URLError>
{
  guard let url = urlRequest.url else { throw makeError(code: .requestHasNoURL) }
  guard let scheme = url.scheme, scheme == "https" else { throw makeError(code: .schemeNotHTTPS) }
  return try makeHTTPResponsePublisher(for: urlRequest, on: urlSession)
}

/// Creates a data task publisher for a URL request where the data is retrievable over HTTP or HTTPS. The output of that publisher is
/// mapped to a `HTTPResponse`.
///
/// - Parameter urlRequest: The URL reques to be made.
/// - Parameter session: The session that will make the request.
///
/// - Returns: A type-erased publisher.
///
///
/// - Throws: All errors are of type `NSError` and will have the domain "HTTPResponse". If the request's URL has any scheme
///   other than "http" or "https" the error code is 102. If the request does not have a URL the error code is 103.
public func makeHTTPResponsePublisher(
  for urlRequest: URLRequest,
  on urlSession: URLSession = .shared)
  throws
  -> AnyPublisher<HTTPResponse, URLError>
{
  guard let url = urlRequest.url else { throw makeError(code: .requestHasNoURL) }
  guard let scheme = url.scheme, ["http", "https"].contains(scheme) else {
    throw makeError(code: .schemeNotHTTPBased)
  }

  return urlSession.dataTaskPublisher(for: urlRequest).eraseToAnyPublisherOfHTTPResponse()
}

extension URLSession.DataTaskPublisher {

  fileprivate func eraseToAnyPublisherOfHTTPResponse() -> AnyPublisher<HTTPResponse, URLError> {
    // Force unwrapping because we've previously verified that the scheme is HTTP-based. Apple
    // documentation says that you will alway get back a `HTTPURLResponse` if you issue a request to
    // a URL with an HTTP-based scheme.
    map { try! HTTPResponse(data: $0, urlResponse: $1) }.eraseToAnyPublisher()
  }
}

private func makeError(code: HTTPResponseError.Code) -> Error {
  NSError(domain: HTTPResponseError.errorDomain, code: code.rawValue)
}
