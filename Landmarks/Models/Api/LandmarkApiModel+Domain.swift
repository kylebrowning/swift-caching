//
//  LandmarkApiModel+Domain.swift
//  Landmarks
//
//  Mapping layer that converts API models to domain models.
//  All validation and filtering happens here.
//

import Foundation

// MARK: - Category Mapping

extension CategoryApiModel {
    /// Converts API category to domain category.
    /// Returns nil for unknown categories, filtering them out.
    var domainModel: Category? {
        switch self {
        case .mountains: .mountains
        case .lakes: .lakes
        case .bridges: .bridges
        case .unknown: nil  // Filter unknown categories
        }
    }
}
// MARK: - Landmark Mapping

extension LandmarkApiModel {
    /// Converts API landmark to domain landmark.
    /// Returns nil if required fields are missing or invalid.
    var domainModel: Landmark? {
        // Validate required fields
        guard let name = name?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty,
              let location = location,
              let description = description,
              let imageName = imageName,
              let apiCategory = category,
              let category = apiCategory.domainModel else {
            return nil
        }

        return Landmark(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            location: location,
            description: description,
            imageName: imageName,
            isFeatured: isFeatured ?? false,
            category: category
        )
    }
}
// MARK: - Convenience for Loading

extension Array where Element == LandmarkApiModel {
    /// Converts array of API models to domain models, filtering invalid entries.
    var domainModels: [Landmark] {
        compactMap(\.domainModel)
    }
}
