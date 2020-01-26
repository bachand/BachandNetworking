import Foundation

extension URLComponents {
  /// Adds the following query items to any existing items.
  public mutating func appendQueryItems(_ additionalItems: [URLQueryItem]) {
    var newItems = [URLQueryItem]()
    newItems = queryItems ?? []
    newItems += additionalItems
    queryItems = newItems
  }
}

/// Creates a URL request.
public func makeURLRequest(_ url: URL) -> URLRequest {
  return URLRequest(url: url)
}

/// Creates a data task.
///
/// - Parameter urlRequest: The request to make.
/// - Parameter session: The session that will make the request.
/// - Parameter stringEncoding: The encoding of the returned data, which will be used to convert the data into a string.
/// - Parameter completionHandler: The completion handler to call when the load request is complete. This handler is executed on the delegate queue of the associated `URLSession`.
/// - Parameter data: The data returned by the server.
/// - Parameter response: An object that provides response metadata, such as HTTP headers and status code. If you are making an HTTP or HTTPS request, the returned object is actually an `HTTPURLResponse` object.
/// - Parameter error: An error object that indicates why the request failed, or `nil` if the request was successful.
public func makeDataTask(
  urlRequest: URLRequest,
  urlSession: URLSession = .shared,
  completionHandler: @escaping (_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) -> Void)
  -> URLSessionDataTask
{
  return urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
    completionHandler(data, urlResponse, error)
  }
}

/// A protocol for fetch data fetching network data.
public protocol DataFetcher {
  /// Peform the fetch.
  ///
  /// - Parameter urlRequest: The URL to fetch.
  /// - Parameter completionHandler: The completion handler to call when the load request is complete. The queue on which the handler is invoked is unspecified.
  /// - Parameter data: The data returned by the server.
  /// - Parameter response: An object that provides response metadata, such as HTTP headers and status code. If you are making an HTTP or HTTPS request, the returned object is actually an `HTTPURLResponse` object.
  /// - Parameter error: An error object that indicates why the request failed, or `nil` if the request was successful.
  func fetch(_ urlRequest: URLRequest, completionHandler: @escaping (_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) -> Void)
}

/// A concrete way to fetch network data.
public final class DefaultDataFetcher: DataFetcher {
  public init(urlSession: URLSession) {
    self.urlSession = urlSession
  }

  public func fetch(_ urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: completionHandler)
    dataTask.resume()
  }

  private let urlSession: URLSession
}

/// A synchronous operation that executes a network request.
public final class DataOperation: Operation {

  public init(dataFetcher: DataFetcher, urlRequest: URLRequest) {
    self.dataFetcher = dataFetcher
    self.urlRequest = urlRequest
  }

  public override func main() {
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    dataFetcher.fetch(urlRequest) { [unowned self ](data, urlResponse, error) in
      self.data = data
      self.urlResponse = urlResponse
      self.error = error
      dispatchGroup.leave()
    }
    dispatchGroup.wait()
  }

  public var data: Data?
  public var urlResponse: URLResponse?
  public var error: Error?

  private let dataFetcher: DataFetcher
  private let urlRequest: URLRequest
}

public func makeDataOperation(urlRequest: URLRequest, urlSession: URLSession = .shared) -> DataOperation {
  let dataFetcher = DefaultDataFetcher(urlSession: urlSession)
  return DataOperation(dataFetcher: dataFetcher, urlRequest: urlRequest)
}
