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

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

## License

MIT
