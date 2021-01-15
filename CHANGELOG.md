# Changelog

## Next version

You can now create a publisher for an `HTTPResponse` with a `URLRequest`, allowing you to add custom headers.

The `makeSecureHTTPResponsePublisher(for:in:)` functions have been renamed to `makeHTTPResponsePublisher(for:in:)` and the `makeHTTPResponsePublisher(for:in:)` functions have been renamed to `makeInsecureHTTPResponsePublisher(for:in:)` to reflect the fact that developers should prefer HTTPS. We've also namespaced the methods to make an `HTTPSResponse` publisher within `URLSession` since that style is generally preferred to free functions.

For each method to make an HTTPResponse we've also added a safe variant. The an example, for the `makeSecureHTTPResponsePublisher(for:in:)` function that creates an `HTTPResponse` publisher from a URL we have added `safeMakeSecureHTTPResponsePublisher(for:in:)`. The unadorned version uses preconditions instead of thrown errors for programmer errors. The safe variants continue to throw when a programmer error is encountered. The non-throwing versions of these methods are more ergonomic and safe when used with discipline.

## 0.0.2

We [explicitly specify the platforms](https://github.com/bachand/BachandNetworking/pull/3) that we support and we [build those platforms in
CI](https://github.com/bachand/BachandNetworking/pull/5). We've [added a `HTTPResponse`](https://github.com/bachand/BachandNetworking/pull/6) to
the public API. `HTTPResponse` is value type. We've added global factory methods for producing type-erased publishers that output a `HTTPResponse`.

## 0.0.1

Initial version.
