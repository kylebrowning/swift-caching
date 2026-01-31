//
//  LandmarksApp.swift
//  Landmarks
//

import SwiftUI

@main
struct LandmarksApp: App {
    /// Create all services once at app startup.
    /// The Services container holds everything the app needs.
    let appServices: Services

    init() {
        // For demo purposes, use mock services.
        // In production, you'd use:
        // appServices = .live(baseURL: URL(string: "http://localhost:8080")!)
        appServices = .mock
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .services(appServices)
        }
    }
}
