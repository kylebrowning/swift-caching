//
//  Environment+Services.swift
//  Landmarks
//
//  SwiftUI environment integration for services.
//  Inject services at the app level, access them anywhere.
//

import SwiftUI

// MARK: - Environment Keys

private struct LandmarkServiceKey: EnvironmentKey {
    static let defaultValue: LandmarkService = .unimplemented
}

private struct AnalyticsServiceKey: EnvironmentKey {
    static let defaultValue: AnalyticsService = .unimplemented
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    var landmarkService: LandmarkService {
        get { self[LandmarkServiceKey.self] }
        set { self[LandmarkServiceKey.self] = newValue }
    }

    var analyticsService: AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}

// MARK: - View Extension for Convenience

extension View {
    func landmarkService(_ service: LandmarkService) -> some View {
        environment(\.landmarkService, service)
    }

    func analyticsService(_ service: AnalyticsService) -> some View {
        environment(\.analyticsService, service)
    }
}
