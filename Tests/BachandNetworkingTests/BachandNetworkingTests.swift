import XCTest
@testable import BachandNetworking

// MARK: - URLComponentsTests

final class URLComponentsTests: XCTestCase {

  func test_appendQueryItems_whenItemsIsNil_addsItem() {
    var urlComponents = URLComponents()
    guard urlComponents.queryItems == nil else { fatalError() }
    let newQueryItem = [URLQueryItem(name: "my", value: "item")]
    urlComponents.appendQueryItems(newQueryItem)
    guard urlComponents.queryItems == [URLQueryItem(name: "my", value: "item")] else { fatalError() }
  }

  func test_appendQueryItems_whenItemsIsEmpty_addsItem() {
    var urlComponents = URLComponents()
    urlComponents.queryItems = []
    guard urlComponents.queryItems == [] else { fatalError() }
    let newQueryItem = [URLQueryItem(name: "my", value: "item")]
    urlComponents.appendQueryItems(newQueryItem)
    guard urlComponents.queryItems == [URLQueryItem(name: "my", value: "item")] else { fatalError() }
  }

  func test_appendQueryItems_whenItemsExist_addsItem() {
    var urlComponents = URLComponents()
    urlComponents.queryItems = [URLQueryItem(name: "my", value: "item")]
    let newQueryItem = [URLQueryItem(name: "my", value: "otherItem")]
    urlComponents.appendQueryItems(newQueryItem)
    let expectedQueryItems = [
      URLQueryItem(name: "my", value: "item"),
      URLQueryItem(name: "my", value: "otherItem")
    ]
    guard urlComponents.queryItems == expectedQueryItems else { fatalError() }
  }
}

// MARK: - DataOperationTests

final class DataOperationTests: XCTestCase {

  func test_start_propagatesData() {
    let mockFetcher = MockDataFetcher()
    mockFetcher.data = Data("hello".utf8)
    let operation = DataOperation(dataFetcher: mockFetcher, urlRequest: makeMockURLRequest())
    operation.start()
    guard let data = operation.data, String(data: data, encoding: .utf8) == "hello" else { fatalError() }
  }

  func test_start_propagatesURLResponse() {
    let mockFetcher = MockDataFetcher()
    mockFetcher.urlResponse = URLResponse(
      url: URL(string: "www.google.com")!,
      mimeType: "mymime",
      expectedContentLength: 10,
      textEncodingName: "myencoding")
    let operation = DataOperation(dataFetcher: mockFetcher, urlRequest: makeMockURLRequest())
    operation.start()
    guard operation.urlResponse?.url?.absoluteString == "www.google.com" else { fatalError() }
  }

  func test_start_propagatesError() {
    enum MyError: Error {
      case failure
    }

    let mockFetcher = MockDataFetcher()
    mockFetcher.error = MyError.failure
    let operation = DataOperation(dataFetcher: mockFetcher, urlRequest: makeMockURLRequest())
    operation.start()
    guard let error = operation.error as? MyError, error == MyError.failure else { fatalError() }
  }

  // MARK: Private

  private func makeMockURLRequest() -> URLRequest {
    let mockURL = URL(string: "/my/fake/url")!
    return URLRequest(url: mockURL)
  }
}

// MARK: - DefaultDataFetcherTests

final class DefaultDataFetcherTests {
  // MARK: Internal

  /// - Attention: This test queries the network, and thus may be flakey
  func test_fetch_retrievesData() {
    let url = URL(string: "http://google.com")!
    let urlRequest = URLRequest(url: url)
    let dataFetcher = DefaultDataFetcher(urlSession: .shared)
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    dataFetcher.fetch(urlRequest) { (data, urlResponse, error) in
      // Google should be more than 100 bytes.
      guard let data = data, data.count > 100 else { fatalError() }
      guard error == nil else { fatalError() }
      dispatchGroup.leave()
    }
    dispatchGroup.wait()
  }
}

// MARK: - MockDataFetcher

final class MockDataFetcher: DataFetcher {
  init(queue: DispatchQueue = .init(label: "com.bachand.MockDataFetcher")) {
    self.queue = queue
  }

  /// The data to pass to the completion handler.
  var data: Data?
  /// The response to pass to the completion handler.
  var urlResponse: URLResponse?
  /// The error to pass to the completion handler.
  var error: Error?

  private(set) var fetchCallCount = 0
  func fetch(
    _ urlRequest: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
  {
    fetchCallCount += 1
    queue.async { [weak self] in
      completionHandler(self?.data, self?.urlResponse, self?.error)
    }
  }

  private let queue: DispatchQueue
}
