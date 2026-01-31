//
//  NetworkClient.swift
//  Landmarks
//
//  A simple network client for making API requests.
//

import Foundation

// MARK: - Network Client

struct NetworkClient: Sendable {
    var fetch: @Sendable (URL) async throws -> Data

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let data = try await fetch(url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Live Implementation

extension NetworkClient {
    static func live(baseURL: URL) -> NetworkClient {
        NetworkClient { url in
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            return data
        }
    }
}

// MARK: - Mock Implementation

extension NetworkClient {
    static var mock: NetworkClient {
        NetworkClient { url in
            // Simulate network delay
            try await Task.sleep(for: .milliseconds(500))

            // Return mock data based on URL path
            let path = url.pathComponents.joined(separator: "/")

            if path.contains("landmarks") {
                return try JSONEncoder().encode(LandmarkListApiResponse(
                    items: LandmarkApiModel.mockApiResponse,
                    hasMore: false,
                    totalCount: LandmarkApiModel.mockApiResponse.count
                ))
            }

            throw NetworkError.notFound
        }
    }
}

// MARK: - Errors

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .notFound:
            return "Resource not found"
        }
    }
}
