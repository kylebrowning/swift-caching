//
//  LandmarkApiModel.swift
//  Landmarks
//
//  API model representing what the server sends.
//  Handles all the quirks of the API response format.
//

import Foundation

/// Marker protocol for API models.
public protocol ApiModel: Codable, Hashable, Equatable {}

/// API response for a single landmark.
/// Matches the server's JSON structure exactly.
public struct LandmarkApiModel: ApiModel, Identifiable {
    public let id: String
    public let name: String?
    public let location: String?
    public let description: String?
    public let imageName: String?
    public let isFeatured: Bool?
    public let category: CategoryApiModel?

    // Server might send extra metadata we don't use
    public let createdAt: Date?
    public let updatedAt: Date?
}

/// API model for category - includes unknown case for forward compatibility.
public enum CategoryApiModel: String, ApiModel {
    case mountains
    case lakes
    case bridges
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CategoryApiModel(rawValue: rawValue) ?? .unknown
    }
}

/// API response wrapper for lists.
public struct LandmarkListApiResponse: ApiModel {
    public let items: [LandmarkApiModel]
    public let hasMore: Bool?
    public let totalCount: Int?
}

// MARK: - Mock API Response

extension LandmarkApiModel {
    /// Simulates what a real API would return - includes edge cases.
    static let mockApiResponse: [LandmarkApiModel] = [
        LandmarkApiModel(
            id: "1",
            name: "Golden Gate Bridge",
            location: "San Francisco, CA",
            description: "An iconic suspension bridge spanning the Golden Gate strait.",
            imageName: "bridge",
            isFeatured: true,
            category: .bridges,
            createdAt: Date(),
            updatedAt: Date()
        ),
        LandmarkApiModel(
            id: "2",
            name: "Yosemite Valley",
            location: "Yosemite National Park, CA",
            description: "A glacial valley known for its granite cliffs and waterfalls.",
            imageName: "mountain",
            isFeatured: true,
            category: .mountains,
            createdAt: Date(),
            updatedAt: nil
        ),
        LandmarkApiModel(
            id: "3",
            name: "Lake Tahoe",
            location: "Sierra Nevada, CA/NV",
            description: "A large freshwater lake known for its clarity and blue color.",
            imageName: "lake",
            isFeatured: false,
            category: .lakes,
            createdAt: nil,
            updatedAt: nil
        ),
        // This one has missing required fields - should be filtered out
        LandmarkApiModel(
            id: "4",
            name: nil,  // Missing name!
            location: "Unknown",
            description: nil,
            imageName: nil,
            isFeatured: nil,
            category: nil,
            createdAt: nil,
            updatedAt: nil
        ),
        LandmarkApiModel(
            id: "5",
            name: "Brooklyn Bridge",
            location: "New York, NY",
            description: "A suspension bridge connecting Manhattan and Brooklyn.",
            imageName: "bridge",
            isFeatured: false,
            category: .bridges,
            createdAt: Date(),
            updatedAt: Date()
        ),
        // This one has an unknown category - should be filtered out
        LandmarkApiModel(
            id: "6",
            name: "Mystery Location",
            location: "Somewhere",
            description: "A mysterious place.",
            imageName: "mystery",
            isFeatured: false,
            category: .unknown,
            createdAt: nil,
            updatedAt: nil
        ),
        LandmarkApiModel(
            id: "7",
            name: "Mount Rainier",
            location: "Washington",
            description: "An active stratovolcano and the most glaciated peak in the US.",
            imageName: "mountain",
            isFeatured: true,
            category: .mountains,
            createdAt: Date(),
            updatedAt: nil
        ),
        LandmarkApiModel(
            id: "8",
            name: "Crater Lake",
            location: "Oregon",
            description: "The deepest lake in the United States.",
            imageName: "lake",
            isFeatured: false,
            category: .lakes,
            createdAt: Date(),
            updatedAt: Date()
        ),
    ]
}
