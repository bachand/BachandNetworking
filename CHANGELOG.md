# Changelog

## Next version

You can now create a publisher for an `HTTPResponse` with a `URLRequest`, allowing you to add custom headers.

The `makeSecureHTTPResponsePublisher(for:in:)` functions have been renamed to `makeHTTPResponsePublisher(for:in:)` and the `makeHTTPResponsePublisher(for:in:)` functions have been renamed to `makeInsecureHTTPResponsePublisher(for:in:)` to reflect the fact that developers should prefer HTTPS. We've also namespaced the methods to make an `HTTPSResponse` publisher within `URLSession` since that style is generally preferred to free functions.

## 0.0.2

We [explicitly specify the platforms](https://github.com/bachand/BachandNetworking/pull/3) that we support and we [build those platforms in
CI](https://github.com/bachand/BachandNetworking/pull/5). We've [added a `HTTPResponse`](https://github.com/bachand/BachandNetworking/pull/6) to
the public API. `HTTPResponse` is value type. We've added global factory methods for producing type-erased publishers that output a `HTTPResponse`.

## 0.0.1

Initial version.
