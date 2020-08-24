//  Created by Michael Bachand on 8/21/20.

import Combine
import Foundation

/// A value type representing a HTTP response.
public struct HTTPResponse {
  /// - Throws: An error if `urlResponse` is any type other than `HTTPURLResponse`. The error will have the domain
  /// "HTTPResponse" and the code 100. The error is of type `NSError`.
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
    case schemeNotSecure = 101
    /// Developer specified a URL that does not have a "http" or "https" scheme.
    case schemeNotHTTPBased = 102
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
/// - Throws: An error if the URL has any scheme other than "https". The error will have the domain "HTTPResponse" and the code
/// 101. The error is of type `NSError`.
public func makeSecureHTTPResponsePublisher(
  for url: URL,
  on urlSession: URLSession = .shared)
  throws
  -> AnyPublisher<HTTPResponse, URLError>
{
  guard let scheme = url.scheme, scheme == "https" else { throw makeError(code: .schemeNotSecure) }
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
/// - Throws: An error if the URL has any scheme other than "http" or "https". The error will have the domain "HTTPResponse" and
/// the code 102. The error is of type `NSError`.
public func makeHTTPResponsePublisher(
  for url: URL,
  on urlSession: URLSession = .shared)
  throws
  -> AnyPublisher<HTTPResponse, URLError>
{
  guard let scheme = url.scheme, ["http", "https"].contains(scheme) else {
    throw makeError(code: .schemeNotHTTPBased)
  }

  let publisher = urlSession.dataTaskPublisher(for: url)
  // Force unwrapping because the scheme is HTTPS. Apple documentation says that you will always
  // give back a `HTTPURLResponse` if you issue a request to a URL with a HTTP scheme.
  return publisher.map { try! HTTPResponse(data: $0, urlResponse: $1) }.eraseToAnyPublisher()
}

private func makeError(code: HTTPResponseError.Code) -> Error {
  NSError(domain: HTTPResponseError.errorDomain, code: code.rawValue)
}
