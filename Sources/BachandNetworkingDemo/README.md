# BachandNetworking Demo CLI Tool

A command-line interface demonstration tool for the BachandNetworking Swift package.

## Overview

This CLI tool showcases the key functionalities of the BachandNetworking package, including:

- **DataOperation**: Synchronous network operations that block until completion
- **DefaultDataFetcher**: Protocol-based data fetching with URLSession
- **URLComponents.appendQueryItems**: Convenient way to build URLs with query parameters
- **makeURLRequest**: Creating URL requests from URLs
- **makeDataOperation**: Factory function for creating data operations

## Building

Build the CLI tool using Swift Package Manager:

```bash
swift build
```

The executable will be created at `.build/debug/BachandNetworkingDemo` (or `.build/release/BachandNetworkingDemo` for release builds).

## Usage

### Basic Syntax

```bash
BachandNetworkingDemo <command> [options]
```

### Commands

#### `fetch` - Fetch data from a URL

Demonstrates using `DataOperation` to synchronously fetch data from a URL.

```bash
BachandNetworkingDemo fetch <url>
```

**Example:**
```bash
BachandNetworkingDemo fetch http://httpbin.org/get
```

**What it demonstrates:**
- Creating a URL request with `makeURLRequest()`
- Creating a data operation with `makeDataOperation()`
- Executing synchronous network requests
- Handling responses and errors

#### `query` - Build URL with query parameters and fetch

Demonstrates using `URLComponents.appendQueryItems()` to build a URL with query parameters.

```bash
BachandNetworkingDemo query <base-url> <key=value>...
```

**Example:**
```bash
BachandNetworkingDemo query http://httpbin.org/get name=John city=NYC age=30
```

**What it demonstrates:**
- Building URLComponents from a base URL
- Using `appendQueryItems()` extension to add query parameters
- Combining URL building with data fetching

#### `help` - Display help information

```bash
BachandNetworkingDemo help
```

## Examples

### Example 1: Simple GET Request

```bash
$ BachandNetworkingDemo fetch http://httpbin.org/get

Fetching URL: http://httpbin.org/get

Response received:
  Status Code: 200
  Headers: ...

Data received (XXX bytes):
{
  "args": {},
  "headers": {
    ...
  },
  "url": "http://httpbin.org/get"
}

✓ Fetch completed successfully
```

### Example 2: GET Request with Query Parameters

```bash
$ BachandNetworkingDemo query http://httpbin.org/get name=Alice city=Seattle

Building URL with query parameters:
  name = Alice
  city = Seattle

Final URL: http://httpbin.org/get?name=Alice&city=Seattle

Response received:
  Status Code: 200

Data received (XXX bytes):
{
  "args": {
    "city": "Seattle",
    "name": "Alice"
  },
  ...
}

✓ Query fetch completed successfully
```

## Testing

Tests for the CLI tool are located in `Tests/BachandNetworkingDemoTests/`. Run tests with:

```bash
swift test --filter BachandNetworkingDemoTests
```

## Features Demonstrated

### 1. Synchronous Network Operations

The `DataOperation` class provides a way to perform network requests synchronously, which is useful in CLI applications and other scenarios where you want to block until the request completes.

```swift
let operation = makeDataOperation(urlRequest: urlRequest)
operation.start()

// Access results after completion
if let data = operation.data {
    // Process data
}
```

### 2. URL Query Parameter Building

The `URLComponents.appendQueryItems()` extension makes it easy to add query parameters to URLs:

```swift
var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
urlComponents.appendQueryItems([
    URLQueryItem(name: "key", value: "value")
])
let finalURL = urlComponents.url
```

### 3. Protocol-Based Data Fetching

The `DataFetcher` protocol allows for testable networking code:

```swift
protocol DataFetcher {
    func fetch(_ urlRequest: URLRequest, 
               completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}
```

## Architecture

The CLI tool is structured as follows:

- **main.swift**: Entry point and command-line parsing
- **Command handlers**: Separate functions for each command (`fetchURL`, `fetchWithQuery`)
- **Error handling**: Proper error messages and exit codes
- **Usage documentation**: Built-in help system

## Requirements

- Swift 5.1 or later
- macOS 10.15+, or Linux with Swift runtime

## Notes

- The CLI tool uses HTTP (not HTTPS) endpoints for testing purposes
- For production use, HTTPS endpoints should be preferred
- The tool limits output to 500 characters for readability
- Network requests are synchronous and will block until completion
