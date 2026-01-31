//
//  CachePolicy.swift
//  Landmarks
//
//  Defines how a service should use the cache for a given request.
//

import Foundation

/// Determines how cached data is used relative to network requests.
public enum CachePolicy: Sendable {
    /// Show cached data immediately, then fetch fresh data.
    /// Best for: Lists and frequently updated content.
    /// The store updates twice - once with cache, once with network.
    case cacheThenFetch

    /// Use cache if available and not expired, otherwise fetch.
    /// Best for: Detail views where slightly stale data is acceptable.
    /// The store updates once - either cache or network, not both.
    case cacheElseFetch

    /// Always fetch from network, ignore cache entirely.
    /// Best for: Actions requiring fresh data (e.g., after a mutation).
    /// The store updates once with network data.
    case networkOnly

    /// Use cache only, never hit the network.
    /// Best for: Offline mode or reducing network usage.
    /// The store updates once with cache, or not at all if empty.
    case cacheOnly

    /// Fetch from network first, fall back to cache on failure.
    /// Best for: When fresh data is preferred but stale is acceptable.
    /// The store updates once - network if successful, cache if not.
    case networkElseCache
}
