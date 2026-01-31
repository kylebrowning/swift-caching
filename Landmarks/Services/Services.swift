//
//  Services.swift
//  Landmarks
//
//  A centralized container for all app services.
//  Inject once at the app level, access individual services as needed.
//

import SwiftUI

// MARK: - Services Container

/// Container that holds all services the app needs.
/// Create once at app startup, inject via environment.
struct Services: Sendable {
    let landmarks: LandmarkService
    let analytics: AnalyticsService
    // Add more services here as the app grows:
    // let users: UserService
    // let auth: AuthService
}

// MARK: - Convenience Factories

extension Services {
    /// Live services connecting to real backend.
    static func live(baseURL: URL) -> Services {
        let client = NetworkClient.live(baseURL: baseURL)
        return Services(
            landmarks: .live(client: client, baseURL: baseURL),
            analytics: .live
        )
    }

    /// Mock services with simulated network delays and caching.
    static var mock: Services {
        let cache = TieredCache.default
        return Services(
            landmarks: .mock(cache: cache),
            analytics: .live  // Still print to console for demo
        )
    }

    /// Preview services with instant data - perfect for SwiftUI previews.
    static var preview: Services {
        Services(
            landmarks: .preview,
            analytics: .preview
        )
    }

    /// Unimplemented services - crashes if called.
    /// Use in tests to catch unexpected service calls.
    static var unimplemented: Services {
        Services(
            landmarks: .unimplemented,
            analytics: .unimplemented
        )
    }
}

// MARK: - Environment Integration

private struct ServicesKey: EnvironmentKey {
    static let defaultValue: Services = .unimplemented
}

extension EnvironmentValues {
    var services: Services {
        get { self[ServicesKey.self] }
        set { self[ServicesKey.self] = newValue }
    }
}

extension View {
    /// Inject services container into the environment.
    func services(_ services: Services) -> some View {
        environment(\.services, services)
            // Also inject individual services for direct access
            .environment(\.landmarkService, services.landmarks)
            .environment(\.analyticsService, services.analytics)
    }
}
