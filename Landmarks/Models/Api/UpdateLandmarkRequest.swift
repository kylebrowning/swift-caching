//
//  UpdateLandmarkRequest.swift
//  Landmarks
//
//  Request type for updating a landmark. Encodes only the fields
//  the server needs - never reuse API models for outbound writes.
//

import Foundation

struct UpdateLandmarkRequest: Encodable, Sendable {
    let name: String
    let location: String
    let description: String
    let imageName: String
    let isFeatured: Bool
    let category: String
}

