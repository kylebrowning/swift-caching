//
//  LandmarkRow.swift
//  Landmarks
//

import SwiftUI

struct LandmarkRow: View {
    let landmark: Landmark

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: landmark.category.systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(landmark.name)
                    .font(.headline)

                Text(landmark.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if landmark.isFeatured {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        LandmarkRow(landmark: Landmark.sampleData[0])
        LandmarkRow(landmark: Landmark.sampleData[2])
    }
}
