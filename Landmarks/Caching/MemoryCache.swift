//
//  MemoryCache.swift
//  Landmarks
//
//  Fast in-memory cache with LRU eviction.
//  Data is lost when the app terminates.
//

import Foundation

/// Actor-based in-memory cache.
/// Uses LRU (Least Recently Used) eviction when capacity is reached.
public actor MemoryCache: CacheServicing {
    /// Storage organized by type identifier, then item id.
    private var storage: [String: [String: Any]] = [:]

    /// Tracks access order for LRU eviction.
    private var accessOrder: [String: [String]] = [:]

    /// Maximum items per type before eviction kicks in.
    private let maxItemsPerType: Int

    public init(maxItemsPerType: Int = 100) {
        self.maxItemsPerType = maxItemsPerType
    }

    public func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>? {
        let typeKey = T.cacheIdentifier

        guard let typeStorage = storage[typeKey],
              let entry = typeStorage[id] as? CacheEntry<T> else {
            return nil
        }

        // Move to end of access order (most recently used)
        updateAccessOrder(typeKey: typeKey, id: id)

        return entry
    }

    public func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async {
        let typeKey = T.cacheIdentifier
        let id = value.cacheId

        // Initialize storage for this type if needed
        if storage[typeKey] == nil {
            storage[typeKey] = [:]
            accessOrder[typeKey] = []
        }

        // Create cache entry
        let expiresAt = expiresIn.map { Date().addingTimeInterval($0) }
        let entry = CacheEntry(value: value, expiresAt: expiresAt)

        // Store and update access order
        storage[typeKey]?[id] = entry
        updateAccessOrder(typeKey: typeKey, id: id)

        // Evict if over capacity
        evictIfNeeded(typeKey: typeKey)
    }

    public func remove<T: Cacheable>(_ type: T.Type, id: String) async {
        let typeKey = T.cacheIdentifier
        storage[typeKey]?[id] = nil
        accessOrder[typeKey]?.removeAll { $0 == id }
    }

    public func removeAll<T: Cacheable>(_ type: T.Type) async {
        let typeKey = T.cacheIdentifier
        storage[typeKey] = nil
        accessOrder[typeKey] = nil
    }

    public func clear() async {
        storage.removeAll()
        accessOrder.removeAll()
    }

    // MARK: - Private Helpers

    private func updateAccessOrder(typeKey: String, id: String) {
        accessOrder[typeKey]?.removeAll { $0 == id }
        accessOrder[typeKey]?.append(id)
    }

    private func evictIfNeeded(typeKey: String) {
        guard let order = accessOrder[typeKey],
              order.count > maxItemsPerType else { return }

        // Remove least recently used items
        let toRemove = order.prefix(order.count - maxItemsPerType)
        for id in toRemove {
            storage[typeKey]?[id] = nil
        }
        accessOrder[typeKey] = Array(order.dropFirst(toRemove.count))
    }
}
