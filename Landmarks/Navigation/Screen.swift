//
//  Screen.swift
//  Landmarks
//

import Foundation

/// The navigation contract for the entire app.
/// Every possible destination has a case in this enum.
public enum Screen: Hashable, Identifiable, Codable {
    case landmarks(LandmarksScreen)
    case favorites(FavoritesScreen)
    case deepLinks(DeepLinksScreen)

    public var id: Self { self }

    // MARK: - Landmarks Tab

    public enum LandmarksScreen: Hashable, Codable {
        case detail(Landmark)
        case category(Category)
        case visitConfirmation(Landmark)
        case edit(Landmark)
    }

    // MARK: - Favorites Tab

    public enum FavoritesScreen: Hashable, Codable {
        case detail(Landmark)
    }

    // MARK: - Deep Links Tab

    public enum DeepLinksScreen: Hashable, Codable {
        case urlResult(URL)
        case servicesDemo
    }
}
