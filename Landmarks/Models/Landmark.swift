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

// MARK: - Sample Data

extension Landmark {
    static let sampleData: [Landmark] = [
        Landmark(
            id: UUID(uuidString: "1") ?? UUID(),
            name: "Golden Gate Bridge",
            location: "San Francisco, CA",
            description: "An iconic suspension bridge.",
            imageName: "goldengate",
            isFeatured: true,
            category: .bridges
        ),
        Landmark(
            id: UUID(uuidString: "2") ?? UUID(),
            name: "Lake Tahoe",
            location: "Sierra Nevada, CA",
            description: "A large freshwater lake in the Sierra Nevada.",
            imageName: "tahoe",
            isFeatured: false,
            category: .lakes
        ),
        Landmark(
            id: UUID(uuidString: "3") ?? UUID(),
            name: "Half Dome",
            location: "Yosemite, CA",
            description: "A granite dome at the eastern end of Yosemite Valley.",
            imageName: "halfdome",
            isFeatured: true,
            category: .mountains
        ),
    ]
}
