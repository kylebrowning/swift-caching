//
//  Navigation+Extensions.swift
//  Landmarks
//

import SwiftUI

// MARK: - View Modifier for Navigation Destination

extension View {
    /// Applies the centralized navigation destination for Screen values.
    func screenDestination(path: Binding<[Screen]>) -> some View {
        self.navigationDestination(for: Screen.self) { screen in
            DestinationContent.content(for: screen, path: path)
        }
    }
}

// MARK: - NavigationLink Convenience

extension NavigationLink where Destination == Never {
    /// Creates a NavigationLink with a Screen value.
    init(screen: Screen, @ViewBuilder label: () -> Label) {
        self.init(value: screen, label: label)
    }
}
