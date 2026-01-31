//
//  LandmarkService.swift
//  Landmarks
//
//  Closure-based service for landmark operations.
//  Now with tiered caching - memory first, disk fallback.
//

import Foundation

// MARK: - Landmark Service

struct LandmarkService: Sendable {
    /// The observable store that views watch directly.
    let store: LandmarkStore

    /// Fetch all landmarks using the specified cache policy.
    var fetchLandmarks: @Sendable (CachePolicy) async throws -> Void

    /// Fetch a single landmark by ID.
    var fetchLandmark: @Sendable (String) async throws -> Landmark?

    /// Fetch landmarks for a specific category.
    var fetchLandmarksByCategory: @Sendable (Category) async throws -> [Landmark]

    /// Clear all cached landmarks.
    var clearCache: @Sendable () async -> Void
}

// MARK: - Live Implementation

extension LandmarkService {
    static func live(
        client: NetworkClient,
        baseURL: URL,
        cache: TieredCache = .default
    ) -> LandmarkService {
        let store = LandmarkStore()

        return LandmarkService(
            store: store,
            fetchLandmarks: { policy in
                switch policy {
                case .cacheThenFetch:
                    // Show cached data immediately if available
                    if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                        await store.setLandmarks(cached, source: .cache)
                    } else {
                        await store.setLoading()
                    }

                    // Then fetch fresh data
                    do {
                        let landmarks = try await fetchFromNetwork(client: client, baseURL: baseURL)
                        await cache.set(landmarks)
                        await store.setLandmarks(landmarks, source: .network)
                    } catch {
                        // Only set error if we had no cached data
                        if store.landmarks.isEmpty {
                            await store.setError(error)
                        }
                        throw error
                    }

                case .cacheElseFetch:
                    // Use cache if available, otherwise fetch
                    if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                        await store.setLandmarks(cached, source: .cache)
                    } else {
                        await store.setLoading()
                        let landmarks = try await fetchFromNetwork(client: client, baseURL: baseURL)
                        await cache.set(landmarks)
                        await store.setLandmarks(landmarks, source: .network)
                    }

                case .networkOnly:
                    await store.setLoading()
                    let landmarks = try await fetchFromNetwork(client: client, baseURL: baseURL)
                    await cache.set(landmarks)
                    await store.setLandmarks(landmarks, source: .network)

                case .cacheOnly:
                    if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                        await store.setLandmarks(cached, source: .cache)
                    }

                case .networkElseCache:
                    await store.setLoading()
                    do {
                        let landmarks = try await fetchFromNetwork(client: client, baseURL: baseURL)
                        await cache.set(landmarks)
                        await store.setLandmarks(landmarks, source: .network)
                    } catch {
                        // Fall back to cache on network failure
                        if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                            await store.setLandmarks(cached, source: .cache)
                        } else {
                            await store.setError(error)
                            throw error
                        }
                    }
                }
            },
            fetchLandmark: { id in
                // Check cache first
                if let cached = await cache.getValue(Landmark.self, id: id) {
                    return cached
                }

                // Fetch from network
                let url = baseURL.appendingPathComponent("landmarks/\(id)")
                let response = try await client.fetch(LandmarkApiModel.self, from: url)
                if let landmark = response.domainModel {
                    await cache.set(landmark)
                    return landmark
                }
                return nil
            },
            fetchLandmarksByCategory: { category in
                let url = baseURL.appendingPathComponent("landmarks/category/\(category.rawValue.lowercased())")
                let response = try await client.fetch(LandmarkListApiResponse.self, from: url)
                return response.items.compactMap(\.domainModel)
            },
            clearCache: {
                await cache.removeAll([Landmark].self)
            }
        )
    }

    private static func fetchFromNetwork(client: NetworkClient, baseURL: URL) async throws -> [Landmark] {
        let url = baseURL.appendingPathComponent("landmarks")
        let response = try await client.fetch(LandmarkListApiResponse.self, from: url)
        return response.items.compactMap(\.domainModel)
    }
}

// MARK: - Mock Implementation

extension LandmarkService {
    static func mock(cache: TieredCache = .default) -> LandmarkService {
        let store = LandmarkStore()

        return LandmarkService(
            store: store,
            fetchLandmarks: { policy in
                let mockData = Landmark.sampleData

                switch policy {
                case .cacheThenFetch:
                    // Show cached data immediately
                    if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                        await store.setLandmarks(cached, source: .cache)
                    } else {
                        await store.setLoading()
                    }

                    // Simulate network delay, then update
                    try await Task.sleep(for: .milliseconds(800))
                    await cache.set(mockData)
                    await store.setLandmarks(mockData, source: .network)

                case .cacheElseFetch:
                    if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                        await store.setLandmarks(cached, source: .cache)
                    } else {
                        await store.setLoading()
                        try await Task.sleep(for: .milliseconds(500))
                        await cache.set(mockData)
                        await store.setLandmarks(mockData, source: .network)
                    }

                case .networkOnly:
                    await store.setLoading()
                    try await Task.sleep(for: .milliseconds(500))
                    await cache.set(mockData)
                    await store.setLandmarks(mockData, source: .network)

                case .cacheOnly:
                    if let cached = await cache.getValue([Landmark].self, id: [Landmark].cacheIdentifier) {
                        await store.setLandmarks(cached, source: .cache)
                    }

                case .networkElseCache:
                    await store.setLoading()
                    try await Task.sleep(for: .milliseconds(500))
                    await cache.set(mockData)
                    await store.setLandmarks(mockData, source: .network)
                }
            },
            fetchLandmark: { id in
                try await Task.sleep(for: .milliseconds(200))
                return Landmark.sampleData
                    .first { $0.id == id }?
                    .domainModel
            },
            fetchLandmarksByCategory: { category in
                try await Task.sleep(for: .milliseconds(300))
                return Landmark.sampleData
                    .compactMap(\.domainModel)
                    .filter { $0.category == category }
            },
            clearCache: {
                await cache.clear()
            }
        )
    }
}

// MARK: - Preview/Test Implementation

extension LandmarkService {
    /// Immediately loaded with sample data - perfect for previews.
    static var preview: LandmarkService {
        let store = LandmarkStore()
        let landmarks = Landmark.sampleData

        // Pre-populate the store
        Task { @MainActor in
            store.setLandmarks(landmarks, source: .cache)
        }

        return LandmarkService(
            store: store,
            fetchLandmarks: { _ in },
            fetchLandmark: { id in landmarks.first { $0.id.uuidString == id } },
            fetchLandmarksByCategory: { category in landmarks.filter { $0.category == category } },
            clearCache: { }
        )
    }

    /// Unimplemented - crashes if called.
    static var unimplemented: LandmarkService {
        LandmarkService(
            store: LandmarkStore(),
            fetchLandmarks: { _ in fatalError("fetchLandmarks not implemented") },
            fetchLandmark: { _ in fatalError("fetchLandmark not implemented") },
            fetchLandmarksByCategory: { _ in fatalError("fetchLandmarksByCategory not implemented") },
            clearCache: { fatalError("clearCache not implemented") }
        )
    }
}
