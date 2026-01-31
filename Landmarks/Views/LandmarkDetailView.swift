//
//  LandmarkDetailView.swift
//  Landmarks
//

import SwiftUI

struct LandmarkDetailView: View {
    let landmark: Landmark

    @Environment(\.toggleFavorite) private var toggleFavorite
    @Environment(\.isFavorite) private var isFavorite
    @Environment(\.analyticsService) private var analytics

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Image
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 250)
                        .overlay {
                            Image(systemName: landmark.category.systemImage)
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.3))
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        if landmark.isFeatured {
                            Label("Featured", systemImage: "star.fill")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.yellow)
                                .foregroundStyle(.black)
                                .clipShape(Capsule())
                        }

                        Text(landmark.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Label(landmark.location, systemImage: "mappin")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding()
                }

                // Content
                VStack(alignment: .leading, spacing: 16) {
                    // Category Badge - tappable link to category list
                    NavigationLink(screen: .landmarks(.category(landmark.category))) {
                        Label(landmark.category.rawValue, systemImage: landmark.category.systemImage)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .foregroundStyle(.primary)
                            .clipShape(Capsule())
                    }

                    // Description
                    Text("About")
                        .font(.headline)

                    Text(landmark.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)

                    // Plan Visit button - demonstrates navigation to confirmation
                    NavigationLink(screen: .landmarks(.visitConfirmation(landmark))) {
                        Text("Plan Visit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle(landmark.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite(landmark.id)
                    Task {
                        await analytics.track(AnalyticsEvent(
                            name: "favorite_toggled",
                            parameters: [
                                "landmark_id": landmark.id.uuidString,
                                "landmark_name": landmark.name,
                                "is_favorite": String(isFavorite(landmark.id))
                            ]
                        ))
                    }
                } label: {
                    Image(systemName: isFavorite(landmark.id) ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite(landmark.id) ? .red : .primary)
                }
            }
        }
        .task {
            await analytics.trackScreenView("LandmarkDetail/\(landmark.name)")
        }
    }
}

#Preview {
    NavigationStack {
        LandmarkDetailView(landmark: Landmark.sampleData[0])
    }
}
