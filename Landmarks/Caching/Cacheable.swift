//
//  Cacheable.swift
//  Landmarks
//
//  Protocol for types that can be cached.
//  Provides identity and type information for cache organization.
//

import Foundation

// MARK: - Cacheable Protocol

/// Types that can be stored in a cache.
/// Requires an identifier for retrieval and a type identifier for organization.
public protocol Cacheable: Codable {
    /// Unique identifier for this item within its type.
    var cacheId: String { get }

    /// Identifier for this type of cached item.
    /// Used to organize cache storage by type.
    static var cacheIdentifier: String { get }
}

// MARK: - Array Conformance

/// Arrays of Cacheable items are themselves Cacheable.
/// Useful for caching list responses.
extension Array: Cacheable where Element: Cacheable {
    public var cacheId: String {
        Self.cacheIdentifier
    }

    public static var cacheIdentifier: String {
        "\(Element.cacheIdentifier)-array"
    }
}

// MARK: - Cache Entry

/// Wrapper that adds metadata to cached items.
/// Tracks when the item was cached and when it expires.
public struct CacheEntry<T: Cacheable>: Codable {
    public let value: T
    public let cachedAt: Date
    public let expiresAt: Date?

    public init(value: T, cachedAt: Date = Date(), expiresAt: Date? = nil) {
        self.value = value
        self.cachedAt = cachedAt
        self.expiresAt = expiresAt
    }

    /// Whether this entry has passed its expiration date.
    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() > expiresAt
    }

    /// How long ago this item was cached, in seconds.
    public var age: TimeInterval {
        Date().timeIntervalSince(cachedAt)
    }
}
