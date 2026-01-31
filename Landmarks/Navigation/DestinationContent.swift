//
//  DestinationContent.swift
//  Landmarks
//

import SwiftUI

/// Centralized view factory that maps Screen cases to their views.
public struct DestinationContent {
    @ViewBuilder
    public static func content(
        for screen: Screen,
        path: Binding<[Screen]>? = nil
    ) -> some View {
        switch screen {
        case let .landmarks(screen):
            LandmarksDestination(screen: screen, path: path)
        case let .favorites(screen):
            FavoritesDestination(screen: screen, path: path)
        case let .deepLinks(screen):
            DeepLinksDestination(screen: screen, path: path)
        }
    }
}

// MARK: - Feature Destinations

struct LandmarksDestination: View {
    let screen: Screen.LandmarksScreen
    var path: Binding<[Screen]>?

    var body: some View {
        switch screen {
        case let .detail(landmark):
            LandmarkDetailView(landmark: landmark)
        case let .category(category):
            CategoryView(category: category)
        case let .visitConfirmation(landmark):
            // Path is required here for pop-to-root functionality
            if let path {
                VisitConfirmationView(landmark: landmark, path: path)
            }
        case let .edit(landmark):
            // Path is required for alert-before-navigation pattern
            if let path {
                EditLandmarkView(landmark: landmark, path: path)
            }
        }
    }
}

struct FavoritesDestination: View {
    let screen: Screen.FavoritesScreen
    var path: Binding<[Screen]>?

    var body: some View {
        switch screen {
        case let .detail(landmark):
            LandmarkDetailView(landmark: landmark)
        }
    }
}

struct DeepLinksDestination: View {
    let screen: Screen.DeepLinksScreen
    var path: Binding<[Screen]>?

    var body: some View {
        switch screen {
        case let .urlResult(url):
            Text("Navigated from: \(url.absoluteString)")
        case .servicesDemo:
            ServicesDemoView()
        }
    }
}
