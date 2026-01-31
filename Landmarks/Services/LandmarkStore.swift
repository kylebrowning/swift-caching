//
//  LandmarkStore.swift
//  Landmarks
//
//  Observable store that holds landmark state.
//  Views observe this directly - no view model needed.
//

import Foundation

// MARK: - Loading State

enum LoadingState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case failed(Error)

    var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var error: Error? {
        if case .failed(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: - Data Source

/// Indicates where data came from - useful for debugging and UI indicators.
enum DataSource: Sendable {
    case cache
    case network
}

// MARK: - Landmark Store

@MainActor
@Observable
final class LandmarkStore {
    private(set) var landmarks: [Landmark] = []
    private(set) var loadingState: LoadingState<[Landmark]> = .idle
    private(set) var selectedLandmark: Landmark?

    /// Where the current data came from (cache or network).
    private(set) var dataSource: DataSource?

    /// When the data was last updated.
    private(set) var lastUpdated: Date?

    // Filtered views of the data
    var featuredLandmarks: [Landmark] {
        landmarks.filter { $0.isFeatured }
    }

    func landmarks(for category: Category) -> [Landmark] {
        landmarks.filter { $0.category == category }
    }

    /// Whether we're showing cached data (and might update soon with fresh data).
    var isShowingCachedData: Bool {
        dataSource == .cache
    }

    // MARK: - State Updates

    func setLoading() {
        loadingState = .loading
    }

    func setLandmarks(_ landmarks: [Landmark], source: DataSource) {
        self.landmarks = landmarks
        self.dataSource = source
        self.lastUpdated = Date()
        loadingState = .loaded(landmarks)
    }

    func setError(_ error: Error) {
        loadingState = .failed(error)
    }

    func setSelectedLandmark(_ landmark: Landmark?) {
        selectedLandmark = landmark
    }
}
