//  BachandNetworkingDemo
//  A demonstration CLI tool for the BachandNetworking package.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import BachandNetworking

// MARK: - CLI Helper Functions

/// Prints the usage information for the CLI tool.
func printUsage() {
  print("""
    BachandNetworking Demo CLI Tool
    ================================
    
    This tool demonstrates the key functionalities of the BachandNetworking package.
    
    USAGE:
        BachandNetworkingDemo <command> [options]
    
    COMMANDS:
        fetch <url>              Fetch data from a URL using DataOperation
        query <base-url> <key=value>...  
                                 Build a URL with query parameters and fetch it
        help                     Display this help message
    
    EXAMPLES:
        BachandNetworkingDemo fetch http://httpbin.org/get
        BachandNetworkingDemo query http://httpbin.org/get name=John city=NYC
    
    FEATURES DEMONSTRATED:
        - DataOperation: Synchronous network operations
        - URLComponents.appendQueryItems: Building URLs with query parameters
        - makeURLRequest: Creating URL requests
        - DefaultDataFetcher: Fetching network data
    """)
}

/// Demonstrates fetching data from a URL using DataOperation.
func fetchURL(_ urlString: String) {
  guard let url = URL(string: urlString) else {
    print("Error: Invalid URL '\(urlString)'")
    exit(1)
  }
  
  print("Fetching URL: \(url.absoluteString)")
  
  // Create a URL request using the BachandNetworking utility
  let urlRequest = makeURLRequest(url)
  
  // Create a DataOperation to fetch the data synchronously
  let operation = makeDataOperation(urlRequest: urlRequest)
  
  // Execute the operation
  operation.start()
  
  // Check for errors
  if let error = operation.error {
    print("Error: \(error.localizedDescription)")
    exit(1)
  }
  
  // Display the response
  if let urlResponse = operation.urlResponse {
    print("\nResponse received:")
    if let httpResponse = urlResponse as? HTTPURLResponse {
      print("  Status Code: \(httpResponse.statusCode)")
      print("  Headers: \(httpResponse.allHeaderFields)")
    } else {
      print("  Response: \(urlResponse)")
    }
  }
  
  // Display the data
  if let data = operation.data {
    print("\nData received (\(data.count) bytes):")
    if let responseString = String(data: data, encoding: .utf8) {
      // Limit output to first 500 characters for readability
      let displayString = responseString.count > 500 
        ? String(responseString.prefix(500)) + "..."
        : responseString
      print(displayString)
    } else {
      print("  (binary data)")
    }
  }
  
  print("\n✓ Fetch completed successfully")
}

/// Demonstrates building a URL with query parameters and fetching it.
func fetchWithQuery(_ baseURLString: String, queryParams: [String]) {
  guard let baseURL = URL(string: baseURLString) else {
    print("Error: Invalid base URL '\(baseURLString)'")
    exit(1)
  }
  
  guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
    print("Error: Could not create URLComponents from base URL")
    exit(1)
  }
  
  // Parse query parameters and build URLQueryItems
  var queryItems: [URLQueryItem] = []
  for param in queryParams {
    let parts = param.split(separator: "=", maxSplits: 1)
    guard parts.count == 2 else {
      print("Error: Invalid query parameter format '\(param)'. Expected 'key=value'")
      exit(1)
    }
    let key = String(parts[0])
    let value = String(parts[1])
    queryItems.append(URLQueryItem(name: key, value: value))
  }
  
  // Use BachandNetworking's URLComponents extension to append query items
  print("Building URL with query parameters:")
  for item in queryItems {
    print("  \(item.name) = \(item.value ?? "")")
  }
  
  urlComponents.appendQueryItems(queryItems)
  
  guard let finalURL = urlComponents.url else {
    print("Error: Could not build final URL")
    exit(1)
  }
  
  print("\nFinal URL: \(finalURL.absoluteString)")
  
  // Now fetch the URL using the same logic as fetchURL
  let urlRequest = makeURLRequest(finalURL)
  let operation = makeDataOperation(urlRequest: urlRequest)
  operation.start()
  
  if let error = operation.error {
    print("Error: \(error.localizedDescription)")
    exit(1)
  }
  
  if let urlResponse = operation.urlResponse {
    print("\nResponse received:")
    if let httpResponse = urlResponse as? HTTPURLResponse {
      print("  Status Code: \(httpResponse.statusCode)")
    }
  }
  
  if let data = operation.data {
    print("\nData received (\(data.count) bytes):")
    if let responseString = String(data: data, encoding: .utf8) {
      let displayString = responseString.count > 500 
        ? String(responseString.prefix(500)) + "..."
        : responseString
      print(displayString)
    }
  }
  
  print("\n✓ Query fetch completed successfully")
}

// MARK: - Main Entry Point

let arguments = CommandLine.arguments

if arguments.count < 2 {
  printUsage()
  exit(0)
}

let command = arguments[1]

switch command {
case "help", "--help", "-h":
  printUsage()
  
case "fetch":
  if arguments.count < 3 {
    print("Error: 'fetch' command requires a URL argument")
    print("Usage: BachandNetworkingDemo fetch <url>")
    exit(1)
  }
  fetchURL(arguments[2])
  
case "query":
  if arguments.count < 4 {
    print("Error: 'query' command requires a base URL and at least one query parameter")
    print("Usage: BachandNetworkingDemo query <base-url> <key=value>...")
    exit(1)
  }
  let baseURL = arguments[2]
  let queryParams = Array(arguments[3...])
  fetchWithQuery(baseURL, queryParams: queryParams)
  
default:
  print("Error: Unknown command '\(command)'")
  printUsage()
  exit(1)
}
