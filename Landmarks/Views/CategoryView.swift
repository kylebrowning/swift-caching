//
//  CategoryView.swift
//  Landmarks
//

import SwiftUI

struct CategoryView: View {
    let category: Category
    @Environment(\.landmarkService) private var landmarkService

    /// Views observe the store directly.
    private var store: LandmarkStore { landmarkService.store }

    var body: some View {
        List(store.landmarks(for: category)) { landmark in
            NavigationLink(screen: .landmarks(.detail(landmark))) {
                LandmarkRow(landmark: landmark)
            }
        }
        .navigationTitle(category.rawValue)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        CategoryView(category: .mountains)
    }
    .services(.preview)
}
