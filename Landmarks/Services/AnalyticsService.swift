//
//  AnalyticsService.swift
//  Landmarks
//
//  Closure-based analytics service.
//  Demonstrates the pattern with a second service.
//

import Foundation

// MARK: - Analytics Event

struct AnalyticsEvent: Sendable {
    let name: String
    let parameters: [String: String]
    let timestamp: Date

    init(name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}

// MARK: - Analytics Service

struct AnalyticsService: Sendable {
    /// Track a user event.
    var track: @Sendable (AnalyticsEvent) async -> Void

    /// Track a screen view.
    var trackScreenView: @Sendable (String) async -> Void

    /// Identify user for analytics.
    var identify: @Sendable (String?) async -> Void
}

// MARK: - Live Implementation

extension AnalyticsService {
    /// Live implementation that would send to a real analytics service.
    static var live: AnalyticsService {
        AnalyticsService(
            track: { event in
                // In production, this would send to your analytics backend
                // e.g., Mixpanel, Amplitude, or custom endpoint
                print("[Analytics] Event: \(event.name), params: \(event.parameters)")
            },
            trackScreenView: { screenName in
                print("[Analytics] Screen view: \(screenName)")
            },
            identify: { userId in
                if let userId {
                    print("[Analytics] Identified user: \(userId)")
                } else {
                    print("[Analytics] Anonymous user")
                }
            }
        )
    }
}

// MARK: - Mock Implementation

extension AnalyticsService {
    /// Mock implementation for testing - collects events in memory.
    static func mock(events: EventCollector = EventCollector()) -> AnalyticsService {
        AnalyticsService(
            track: { event in
                await events.add(event)
            },
            trackScreenView: { screenName in
                await events.add(AnalyticsEvent(name: "screen_view", parameters: ["screen": screenName]))
            },
            identify: { userId in
                await events.add(AnalyticsEvent(name: "identify", parameters: ["user_id": userId ?? "anonymous"]))
            }
        )
    }

    /// Silent mock - does nothing. Good for previews.
    static var preview: AnalyticsService {
        AnalyticsService(
            track: { _ in },
            trackScreenView: { _ in },
            identify: { _ in }
        )
    }

    /// Unimplemented - crashes if called.
    static var unimplemented: AnalyticsService {
        AnalyticsService(
            track: { _ in fatalError("track not implemented") },
            trackScreenView: { _ in fatalError("trackScreenView not implemented") },
            identify: { _ in fatalError("identify not implemented") }
        )
    }
}

// MARK: - Event Collector (for testing)

/// Collects analytics events for testing verification.
actor EventCollector {
    private(set) var events: [AnalyticsEvent] = []

    func add(_ event: AnalyticsEvent) {
        events.append(event)
    }

    func clear() {
        events.removeAll()
    }
}
