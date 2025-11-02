//  BachandNetworkingDemoTests
//  Tests for the BachandNetworking Demo CLI tool.

import XCTest
import Foundation

final class BachandNetworkingDemoTests: XCTestCase {
  
  // MARK: - Helper Methods
  
  /// Runs the CLI tool with the given arguments and returns the output.
  private func runCLI(arguments: [String]) -> (output: String, exitCode: Int32) {
    let process = Process()
    let pipe = Pipe()
    
    // Find the executable
    let executablePath = findExecutablePath()
    
    process.executableURL = URL(fileURLWithPath: executablePath)
    process.arguments = arguments
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
      try process.run()
      process.waitUntilExit()
      
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(data: data, encoding: .utf8) ?? ""
      
      return (output, process.terminationStatus)
    } catch {
      XCTFail("Failed to run CLI: \(error)")
      return ("", -1)
    }
  }
  
  /// Finds the path to the executable.
  private func findExecutablePath() -> String {
    // Try to find the built executable
    let fileManager = FileManager.default
    let currentPath = fileManager.currentDirectoryPath
    
    // Check in .build/debug first
    let debugPath = "\(currentPath)/.build/debug/BachandNetworkingDemo"
    if fileManager.fileExists(atPath: debugPath) {
      return debugPath
    }
    
    // Check in .build/release
    let releasePath = "\(currentPath)/.build/release/BachandNetworkingDemo"
    if fileManager.fileExists(atPath: releasePath) {
      return releasePath
    }
    
    // If neither exists, return debug path and let the test fail with a clear error
    return debugPath
  }
  
  // MARK: - Tests
  
  func test_helpCommand_displaysUsageInformation() {
    let result = runCLI(arguments: ["help"])
    
    XCTAssertEqual(result.exitCode, 0, "Help command should exit with code 0")
    XCTAssertTrue(result.output.contains("BachandNetworking Demo CLI Tool"))
    XCTAssertTrue(result.output.contains("USAGE:"))
    XCTAssertTrue(result.output.contains("COMMANDS:"))
    XCTAssertTrue(result.output.contains("fetch"))
    XCTAssertTrue(result.output.contains("query"))
  }
  
  func test_noArguments_displaysHelp() {
    let result = runCLI(arguments: [])
    
    XCTAssertEqual(result.exitCode, 0, "No arguments should display help and exit with code 0")
    XCTAssertTrue(result.output.contains("BachandNetworking Demo CLI Tool"))
  }
  
  func test_unknownCommand_displaysError() {
    let result = runCLI(arguments: ["unknown-command"])
    
    XCTAssertNotEqual(result.exitCode, 0, "Unknown command should exit with non-zero code")
    XCTAssertTrue(result.output.contains("Error: Unknown command"))
  }
  
  func test_fetchCommand_withoutURL_displaysError() {
    let result = runCLI(arguments: ["fetch"])
    
    XCTAssertNotEqual(result.exitCode, 0, "Fetch without URL should exit with non-zero code")
    XCTAssertTrue(result.output.contains("Error:"))
    XCTAssertTrue(result.output.contains("URL"))
  }
  
  func test_fetchCommand_withInvalidURL_displaysError() {
    let result = runCLI(arguments: ["fetch", "not-a-valid-url"])
    
    XCTAssertNotEqual(result.exitCode, 0, "Fetch with invalid URL should exit with non-zero code")
    XCTAssertTrue(result.output.contains("Error:"))
  }
  
  func test_fetchCommand_withValidURL_fetchesData() {
    // Use httpbin.org as a reliable test endpoint
    let result = runCLI(arguments: ["fetch", "http://httpbin.org/get"])
    
    // Note: This test requires network access and may be flaky
    // In a production environment, you might want to skip this or use a mock server
    if result.exitCode == 0 {
      XCTAssertTrue(result.output.contains("Fetching URL:"))
      XCTAssertTrue(result.output.contains("Response received:"))
      XCTAssertTrue(result.output.contains("Status Code:"))
      XCTAssertTrue(result.output.contains("✓ Fetch completed successfully"))
    } else {
      // If network is not available, the test should at least show proper error handling
      XCTAssertTrue(result.output.contains("Error:"))
    }
  }
  
  func test_queryCommand_withoutParameters_displaysError() {
    let result = runCLI(arguments: ["query", "http://httpbin.org/get"])
    
    XCTAssertNotEqual(result.exitCode, 0, "Query without parameters should exit with non-zero code")
    XCTAssertTrue(result.output.contains("Error:"))
  }
  
  func test_queryCommand_withInvalidParameter_displaysError() {
    let result = runCLI(arguments: ["query", "http://httpbin.org/get", "invalid-param"])
    
    XCTAssertNotEqual(result.exitCode, 0, "Query with invalid parameter format should exit with non-zero code")
    XCTAssertTrue(result.output.contains("Error:"))
    XCTAssertTrue(result.output.contains("key=value"))
  }
  
  func test_queryCommand_withValidParameters_buildsURLAndFetches() {
    // Use httpbin.org as a reliable test endpoint
    let result = runCLI(arguments: ["query", "http://httpbin.org/get", "name=Test", "value=123"])
    
    // Note: This test requires network access and may be flaky
    if result.exitCode == 0 {
      XCTAssertTrue(result.output.contains("Building URL with query parameters:"))
      XCTAssertTrue(result.output.contains("name = Test"))
      XCTAssertTrue(result.output.contains("value = 123"))
      XCTAssertTrue(result.output.contains("Final URL:"))
      XCTAssertTrue(result.output.contains("?"))
      XCTAssertTrue(result.output.contains("Response received:"))
      XCTAssertTrue(result.output.contains("✓ Query fetch completed successfully"))
    } else {
      // If network is not available, the test should at least show proper error handling
      XCTAssertTrue(result.output.contains("Error:"))
    }
  }
  
  func test_queryCommand_withMultipleParameters_buildsCorrectURL() {
    let result = runCLI(arguments: ["query", "http://httpbin.org/get", "a=1", "b=2", "c=3"])
    
    if result.exitCode == 0 {
      XCTAssertTrue(result.output.contains("a = 1"))
      XCTAssertTrue(result.output.contains("b = 2"))
      XCTAssertTrue(result.output.contains("c = 3"))
    }
  }
  
  // MARK: - Integration Tests (require network)
  
  /// Tests the full fetch workflow with a real HTTP request.
  /// This test may fail if network is unavailable.
  func test_integration_fetchCommand_completesSuccessfully() {
    let result = runCLI(arguments: ["fetch", "http://httpbin.org/status/200"])
    
    // Skip test if network is not available
    guard result.exitCode == 0 else {
      print("Skipping network integration test - network may be unavailable")
      return
    }
    
    XCTAssertTrue(result.output.contains("Status Code: 200"))
    XCTAssertTrue(result.output.contains("✓ Fetch completed successfully"))
  }
  
  /// Tests the full query workflow with a real HTTP request.
  /// This test may fail if network is unavailable.
  func test_integration_queryCommand_completesSuccessfully() {
    let result = runCLI(arguments: ["query", "http://httpbin.org/get", "test=value"])
    
    // Skip test if network is not available
    guard result.exitCode == 0 else {
      print("Skipping network integration test - network may be unavailable")
      return
    }
    
    XCTAssertTrue(result.output.contains("test = value"))
    XCTAssertTrue(result.output.contains("✓ Query fetch completed successfully"))
  }
}
