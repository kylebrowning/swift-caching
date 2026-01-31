//
//  TieredCache.swift
//  Landmarks
//
//  Combines memory and disk caches for optimal performance.
//  Checks memory first (fast), falls back to disk, promotes hits to memory.
//

import Foundation

/// A cache that checks multiple layers in order.
/// Memory is checked first for speed, disk for persistence.
/// Items found on disk are promoted to memory for future fast access.
public struct TieredCache: CacheServicing, Sendable {
    private let memory: MemoryCache
    private let disk: DiskCache

    public init(memory: MemoryCache = MemoryCache(), disk: DiskCache = DiskCache()) {
        self.memory = memory
        self.disk = disk
    }

    /// Default tiered cache with standard settings.
    public static let `default` = TieredCache()

    public func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>? {
        // Check memory first (fast path)
        if let entry = await memory.get(type, id: id) {
            return entry
        }

        // Fall back to disk
        if let entry = await disk.get(type, id: id) {
            // Promote to memory for next time
            await memory.set(entry.value, expiresIn: entry.expiresAt.map { $0.timeIntervalSinceNow })
            return entry
        }

        return nil
    }

    public func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async {
        // Write to both layers
        await memory.set(value, expiresIn: expiresIn)
        await disk.set(value, expiresIn: expiresIn)
    }

    public func remove<T: Cacheable>(_ type: T.Type, id: String) async {
        await memory.remove(type, id: id)
        await disk.remove(type, id: id)
    }

    public func removeAll<T: Cacheable>(_ type: T.Type) async {
        await memory.removeAll(type)
        await disk.removeAll(type)
    }

    public func clear() async {
        await memory.clear()
        await disk.clear()
    }

    // MARK: - Layer-Specific Operations

    /// Clear only the memory cache.
    /// Useful when responding to memory warnings.
    public func clearMemory() async {
        await memory.clear()
    }

    /// Get the total size of the disk cache in bytes.
    public func diskSize() async -> Int64 {
        await disk.totalSize()
    }

    /// Remove disk entries older than a given date.
    public func pruneOlderThan(_ date: Date) async {
        await disk.removeOlderThan(date)
    }
}
