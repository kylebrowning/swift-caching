//
//  Landmark.swift
//  Landmarks
//
//  Domain model representing a validated, ready-to-use landmark.
//  This is what views and business logic work with.
//

import Foundation

/// Marker protocol for domain models.
public protocol DomainModel: Codable, Equatable, Hashable {}

public struct Landmark: DomainModel, Identifiable, Cacheable {
    public let id: UUID
    public let name: String
    public let location: String
    public let description: String
    public let imageName: String
    public let isFeatured: Bool
    public let category: Category

    public init(
        id: UUID = UUID(),
        name: String,
        location: String,
        description: String,
        imageName: String,
        isFeatured: Bool = false,
        category: Category
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.description = description
        self.imageName = imageName
        self.isFeatured = isFeatured
        self.category = category
    }

    // MARK: - Business Logic

    /// Display title combining name and location.
    public var displayTitle: String {
        "\(name), \(location)"
    }

    // MARK: - Cacheable

    public var cacheId: String { id.uuidString }
    public static var cacheIdentifier: String { "landmarks" }
}

// MARK: - Sample Data (via API Model conversion)

extension Landmark {
    /// Sample data loaded by converting mock API responses.
    /// This simulates how real data would flow: API → Domain.
    /// Notice that invalid entries (missing name, unknown category) are filtered out.
    static let sampleData: [Landmark] = LandmarkApiModel.mockApiResponse.domainModels
}
