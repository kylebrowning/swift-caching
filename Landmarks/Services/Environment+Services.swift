//
//  Environment+Services.swift
//  Landmarks
//
//  SwiftUI environment integration for services.
//  Inject services at the app level, access them anywhere.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var landmarkService: LandmarkService = .unimplemented
    @Entry var analyticsService: AnalyticsService = .unimplemented
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
