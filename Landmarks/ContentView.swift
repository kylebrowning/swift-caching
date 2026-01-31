//
//  ContentView.swift
//  Landmarks
//

import SwiftUI

struct ContentView: View {
    @Environment(\.landmarkService) private var landmarkService
    @State private var navigator = Navigator()
    @State private var favorites: Set<UUID> = []

    var body: some View {
        @Bindable var navigator = navigator

        TabView(selection: $navigator.selectedTab) {
            NavigationStack(path: $navigator.landmarksPath) {
                LandmarkListView()
                    .screenDestination(path: $navigator.landmarksPath)
            }
            .tabItem { Label("Landmarks", systemImage: "map") }
            .tag(Navigator.Tab.landmarks)

            NavigationStack(path: $navigator.favoritesPath) {
                FavoritesView(favorites: $favorites)
                    .screenDestination(path: $navigator.favoritesPath)
            }
            .tabItem { Label("Favorites", systemImage: "heart") }
            .tag(Navigator.Tab.favorites)

            NavigationStack(path: $navigator.deepLinksPath) {
                DeepLinksView()
                    .screenDestination(path: $navigator.deepLinksPath)
            }
            .tabItem { Label("Deep Links", systemImage: "link") }
            .tag(Navigator.Tab.deepLinks)
        }
        .environment(navigator)
        .environment(\.toggleFavorite, toggleFavorite)
        .environment(\.isFavorite, isFavorite)
        .onOpenURL { url in
            navigator.handleDeepLink(url)
        }
        .onAppear {
            navigator.loadState()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            navigator.saveState()
        }
        .task {
            // Load landmarks when the app starts.
            // Using cacheThenFetch: shows cached data immediately, then refreshes.
            try? await landmarkService.fetchLandmarks(.cacheThenFetch)
        }
    }

    private func toggleFavorite(_ id: UUID) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
    }

    private func isFavorite(_ id: UUID) -> Bool {
        favorites.contains(id)
    }
}

// MARK: - Environment Keys for Favorites

extension EnvironmentValues {
    @Entry var toggleFavorite: (UUID) -> Void = { _ in }
    @Entry var isFavorite: (UUID) -> Bool = { _ in false }
}

#Preview {
    ContentView()
        .services(.preview)
}
