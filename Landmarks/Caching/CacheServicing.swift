//
//  CacheServicing.swift
//  Landmarks
//
//  Protocol defining cache operations.
//  Implementations can be memory, disk, or tiered.
//

import Foundation

/// Protocol for cache implementations.
/// Supports storing, retrieving, and removing cached items.
public protocol CacheServicing: Sendable {
    /// Retrieve an item from the cache.
    func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>?

    /// Store an item in the cache.
    func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async

    /// Remove a specific item from the cache.
    func remove<T: Cacheable>(_ type: T.Type, id: String) async

    /// Remove all items of a specific type.
    func removeAll<T: Cacheable>(_ type: T.Type) async

    /// Clear the entire cache.
    func clear() async
}

// MARK: - Convenience Extensions

extension CacheServicing {
    /// Store an item with default expiration (nil = never expires).
    public func set<T: Cacheable>(_ value: T) async {
        await set(value, expiresIn: nil)
    }

    /// Get a value directly, unwrapping the cache entry.
    /// Returns nil if not cached or expired.
    public func getValue<T: Cacheable>(_ type: T.Type, id: String) async -> T? {
        guard let entry = await get(type, id: id) else { return nil }
        guard !entry.isExpired else {
            await remove(type, id: id)
            return nil
        }
        return entry.value
    }
}
