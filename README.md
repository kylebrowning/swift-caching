# Tiered Caching in Swift

A two-layer cache with memory and disk storage, LRU eviction, and flexible fetch policies.

This is the companion project for the blog post: [Tiered Caching in Swift](https://kylebrowning.com/posts/tiered-caching-in-swift)

## Overview

This project demonstrates:

- `Cacheable` protocol for type-safe caching
- Memory cache with LRU eviction
- Disk cache with JSON persistence
- Tiered cache combining both layers
- Cache policies (cacheThenFetch, cacheElseFetch, networkOnly, cacheOnly, networkElseCache)
- Integration with observable stores for automatic UI updates

## Part of the Landmarks Series

This project is part of a [10-part series](https://kylebrowning.com/series/landmarks-app) on building a full-stack Swift app.

| # | Topic | Code |
|---|-------|------|
| 1 | [SwiftUI Navigation](https://kylebrowning.com/posts/swiftui-navigation-the-easy-way) | [Code](https://github.com/kylebrowning/swiftui-navigation-the-easy-way) |
| 2 | [Domain Models vs API Models](https://kylebrowning.com/posts/domain-models-vs-api-models) | [Code](https://github.com/kylebrowning/domain-models-vs-api-models) |
| 3 | [Dependency Injection](https://kylebrowning.com/posts/dependency-injection-in-swiftui) | [Code](https://github.com/kylebrowning/swift-dependency-injection) |
| **4** | **[Tiered Caching](https://kylebrowning.com/posts/tiered-caching-in-swift)** | **This repo** |
| 5 | [Vapor Backend](https://kylebrowning.com/posts/vapor-backend-for-landmarks) | [Code](https://github.com/kylebrowning/vapor-backend-for-landmarks) |
| 6 | [Full Landmarks App](https://kylebrowning.com/posts/building-the-full-landmarks-app) | [Code](https://github.com/kylebrowning/landmarks-app-complete) |
| 7 | [Deploy to AWS](https://kylebrowning.com/posts/deploying-vapor-to-aws) | [Code](https://github.com/kylebrowning/vapor-landmarks-deploy) |
| 8 | [Server Integration Testing](https://kylebrowning.com/posts/vapor-integration-testing) | [Code](https://github.com/kylebrowning/vapor-integration-testing) |
| 9 | [iOS App Testing](https://kylebrowning.com/posts/testing-landmarks-app) | [Code](https://github.com/kylebrowning/testing-landmarks-app) |
| 10 | [Maestro UI Testing](https://kylebrowning.com/posts/maestro-ui-testing) | [Code](https://github.com/kylebrowning/maestro-ui-testing) |

## License

MIT
