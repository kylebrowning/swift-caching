//
//  DiskCache.swift
//  Landmarks
//
//  Persistent file-based cache using JSON serialization.
//  Survives app termination and device restarts.
//

import Foundation

/// Actor-based disk cache using JSON files.
/// Organizes files by type in subdirectories.
public actor DiskCache: CacheServicing {
    private let baseDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directory: URL? = nil) {
        if let directory {
            self.baseDirectory = directory
        } else {
            // Default to Caches directory
            let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            self.baseDirectory = caches.appendingPathComponent("AppCache", isDirectory: true)
        }
    }

    public func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>? {
        let fileURL = fileURL(for: type, id: id)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(CacheEntry<T>.self, from: data)
        } catch {
            // Corrupted file - remove it
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
    }

    public func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async {
        let typeKey = T.cacheIdentifier
        let id = value.cacheId
        let fileURL = fileURL(for: T.self, id: id)

        // Ensure directory exists
        let typeDirectory = baseDirectory.appendingPathComponent(sanitize(typeKey), isDirectory: true)
        try? FileManager.default.createDirectory(at: typeDirectory, withIntermediateDirectories: true)

        // Create and write entry
        let expiresAt = expiresIn.map { Date().addingTimeInterval($0) }
        let entry = CacheEntry(value: value, expiresAt: expiresAt)

        do {
            let data = try encoder.encode(entry)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Log error in production, silently fail for demo
        }
    }

    public func remove<T: Cacheable>(_ type: T.Type, id: String) async {
        let fileURL = fileURL(for: type, id: id)
        try? FileManager.default.removeItem(at: fileURL)
    }

    public func removeAll<T: Cacheable>(_ type: T.Type) async {
        let typeDirectory = baseDirectory.appendingPathComponent(sanitize(T.cacheIdentifier), isDirectory: true)
        try? FileManager.default.removeItem(at: typeDirectory)
    }

    public func clear() async {
        try? FileManager.default.removeItem(at: baseDirectory)
    }

    // MARK: - Maintenance

    /// Calculate total size of cached files in bytes.
    public func totalSize() -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: baseDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                total += Int64(size)
            }
        }
        return total
    }

    /// Remove cache entries older than a given date.
    public func removeOlderThan(_ date: Date) async {
        guard let enumerator = FileManager.default.enumerator(
            at: baseDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return }

        for case let fileURL as URL in enumerator {
            guard let modDate = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                  modDate < date else { continue }
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // MARK: - Private Helpers

    private func fileURL<T: Cacheable>(for type: T.Type, id: String) -> URL {
        let typeDirectory = baseDirectory.appendingPathComponent(sanitize(T.cacheIdentifier), isDirectory: true)
        return typeDirectory.appendingPathComponent(sanitize(id) + ".json")
    }

    private func sanitize(_ string: String) -> String {
        // Remove characters that are problematic in file paths
        string.replacingOccurrences(of: "/", with: "-")
              .replacingOccurrences(of: ":", with: "-")
    }
}
