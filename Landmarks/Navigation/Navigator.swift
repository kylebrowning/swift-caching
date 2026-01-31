//
//  Navigator.swift
//  Landmarks
//

import SwiftUI

/// Centralized navigation state that can handle deep links and programmatic navigation.
@Observable
final class Navigator {
    var selectedTab: Tab = .landmarks
    var landmarksPath: [Screen] = []
    var favoritesPath: [Screen] = []
    var deepLinksPath: [Screen] = []

    enum Tab: String, Hashable, Codable {
        case landmarks
        case favorites
        case deepLinks
    }

    // MARK: - Deep Link Handling

    func handleDeepLink(_ url: URL) {
        guard let screens = parseURL(url) else { return }
        navigate(to: screens)
    }

    /// Navigate to a specific screen path, switching tabs if needed.
    func navigate(to screens: [Screen]) {
        guard let first = screens.first else { return }

        // Determine which tab this navigation belongs to
        switch first {
        case .landmarks:
            selectedTab = .landmarks
            landmarksPath = screens
        case .favorites:
            selectedTab = .favorites
            favoritesPath = screens
        case .deepLinks:
            selectedTab = .deepLinks
            deepLinksPath = screens
        }
    }

    /// Navigate to a single screen.
    func navigate(to screen: Screen) {
        navigate(to: [screen])
    }

    /// Push a screen onto the current tab's stack.
    func push(_ screen: Screen) {
        switch selectedTab {
        case .landmarks:
            landmarksPath.append(screen)
        case .favorites:
            favoritesPath.append(screen)
        case .deepLinks:
            deepLinksPath.append(screen)
        }
    }

    /// Pop the top screen from the current tab's stack.
    func pop() {
        switch selectedTab {
        case .landmarks:
            if !landmarksPath.isEmpty { landmarksPath.removeLast() }
        case .favorites:
            if !favoritesPath.isEmpty { favoritesPath.removeLast() }
        case .deepLinks:
            if !deepLinksPath.isEmpty { deepLinksPath.removeLast() }
        }
    }

    /// Pop to root in the current tab.
    func popToRoot() {
        switch selectedTab {
        case .landmarks:
            landmarksPath = []
        case .favorites:
            favoritesPath = []
        case .deepLinks:
            deepLinksPath = []
        }
    }

    /// Replace the entire navigation stack for the current tab.
    /// Useful for login flows or onboarding completion.
    func replaceStack(with screens: [Screen]) {
        switch selectedTab {
        case .landmarks:
            landmarksPath = screens
        case .favorites:
            favoritesPath = screens
        case .deepLinks:
            deepLinksPath = screens
        }
    }

    // MARK: - State Restoration

    /// The state that can be persisted and restored.
    struct RestorationState: Codable {
        let selectedTab: Tab
        let landmarksPath: [Screen]
        let favoritesPath: [Screen]
        let deepLinksPath: [Screen]
    }

    /// Capture the current navigation state for persistence.
    func captureState() -> RestorationState {
        RestorationState(
            selectedTab: selectedTab,
            landmarksPath: landmarksPath,
            favoritesPath: favoritesPath,
            deepLinksPath: deepLinksPath
        )
    }

    /// Restore navigation state from a previously captured state.
    func restore(from state: RestorationState) {
        selectedTab = state.selectedTab
        landmarksPath = state.landmarksPath
        favoritesPath = state.favoritesPath
        deepLinksPath = state.deepLinksPath
    }

    /// Save state to UserDefaults.
    func saveState() {
        let state = captureState()
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "NavigatorState")
        }
    }

    /// Load state from UserDefaults.
    func loadState() {
        guard let data = UserDefaults.standard.data(forKey: "NavigatorState"),
              let state = try? JSONDecoder().decode(RestorationState.self, from: data) else {
            return
        }
        restore(from: state)
    }

    /// Clear saved state.
    func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: "NavigatorState")
    }

    // MARK: - URL Parsing

    private func parseURL(_ url: URL) -> [Screen]? {
        // Example URL scheme: landmarks://landmark/golden-gate-bridge
        // or: landmarks://category/mountains

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let first = pathComponents.first else { return nil }

        switch first {
        case "landmark":
            if let name = pathComponents.dropFirst().first,
               let landmark = Landmark.sampleData.first(where: {
                   $0.name.lowercased().replacingOccurrences(of: " ", with: "-") == name.lowercased()
               }) {
                return [.landmarks(.detail(landmark))]
            }
        case "category":
            if let categoryName = pathComponents.dropFirst().first,
               let category = Category.allCases.first(where: {
                   $0.rawValue.lowercased() == categoryName.lowercased()
               }) {
                return [.landmarks(.category(category))]
            }
        default:
            break
        }

        return nil
    }
}
