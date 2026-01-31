//
//  Category.swift
//  Landmarks
//
//  Domain model for landmark categories.
//  No "unknown" case - invalid categories are filtered at the mapping layer.
//

import Foundation

public enum Category: String, DomainModel, CaseIterable, Identifiable {
    case mountains = "Mountains"
    case lakes = "Lakes"
    case bridges = "Bridges"

    public var id: String { rawValue }

    public var systemImage: String {
        switch self {
        case .mountains: "mountain.2"
        case .lakes: "water.waves"
        case .bridges: "road.lanes"
        }
    }
}
