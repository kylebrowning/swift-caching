//
//  DeepLinksView.swift
//  Landmarks
//

import SwiftUI

/// Demonstrates programmatic navigation and deep linking.
struct DeepLinksView: View {
    @Environment(Navigator.self) private var navigator

    // For presenting screens in place (sheet/fullScreenCover)
    @State private var sheetLandmark: Landmark?
    @State private var fullScreenLandmark: Landmark?

    var body: some View {
        List {
            Section {
                Text("Tap any button below to navigate programmatically. This simulates handling deep links, push notifications, or any external navigation trigger.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Caching") {
                NavigationLink(screen: .deepLinks(.servicesDemo)) {
                    VStack(alignment: .leading) {
                        Label("Caching Demo", systemImage: "internaldrive")
                        Text("Test cache policies and see the store update")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Navigate to Landmarks") {
                ForEach(Landmark.sampleData.prefix(3)) { landmark in
                    Button {
                        navigator.navigate(to: .landmarks(.detail(landmark)))
                    } label: {
                        Label(landmark.name, systemImage: landmark.category.systemImage)
                    }
                }
            }

            Section("Navigate to Categories") {
                ForEach(Category.allCases) { category in
                    Button {
                        navigator.navigate(to: .landmarks(.category(category)))
                    } label: {
                        Label(category.rawValue, systemImage: category.systemImage)
                    }
                }
            }

            Section("Multi-Screen Navigation") {
                Button {
                    // Navigate to a category, then immediately to a detail
                    let landmark = Landmark.sampleData.first { $0.category == .mountains }!
                    navigator.navigate(to: [
                        .landmarks(.category(.mountains)),
                        .landmarks(.detail(landmark))
                    ])
                } label: {
                    VStack(alignment: .leading) {
                        Label("Mountains → Yosemite Valley", systemImage: "arrow.right.circle")
                        Text("Pushes two screens onto the stack")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Simulated URL Deep Links") {
                Button {
                    let url = URL(string: "landmarks://landmark/golden-gate-bridge")!
                    navigator.handleDeepLink(url)
                } label: {
                    VStack(alignment: .leading) {
                        Label("landmarks://landmark/golden-gate-bridge", systemImage: "link")
                            .font(.footnote)
                        Text("Opens Golden Gate Bridge detail")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    let url = URL(string: "landmarks://category/lakes")!
                    navigator.handleDeepLink(url)
                } label: {
                    VStack(alignment: .leading) {
                        Label("landmarks://category/lakes", systemImage: "link")
                            .font(.footnote)
                        Text("Opens Lakes category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Present in Place") {
                Button {
                    sheetLandmark = Landmark.sampleData[0]
                } label: {
                    VStack(alignment: .leading) {
                        Label("Show as Sheet", systemImage: "rectangle.bottomhalf.inset.filled")
                        Text("Preview Golden Gate Bridge without leaving this tab")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    fullScreenLandmark = Landmark.sampleData[1]
                } label: {
                    VStack(alignment: .leading) {
                        Label("Show as Full Screen", systemImage: "rectangle.inset.filled")
                        Text("Preview Yosemite Valley in full screen cover")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Alert Before Navigation") {
                Button {
                    navigator.navigate(to: .landmarks(.edit(Landmark.sampleData[0])))
                } label: {
                    VStack(alignment: .leading) {
                        Label("Edit Landmark", systemImage: "pencil")
                        Text("Shows discard confirmation when leaving with changes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("State Restoration") {
                Button {
                    navigator.saveState()
                } label: {
                    VStack(alignment: .leading) {
                        Label("Save Navigation State", systemImage: "square.and.arrow.down")
                        Text("Persists current tab and navigation paths")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    navigator.loadState()
                } label: {
                    VStack(alignment: .leading) {
                        Label("Restore Navigation State", systemImage: "square.and.arrow.up")
                        Text("Restores previously saved state")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button(role: .destructive) {
                    navigator.clearSavedState()
                } label: {
                    VStack(alignment: .leading) {
                        Label("Clear Saved State", systemImage: "trash")
                        Text("Removes persisted navigation state")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Deep Links")
        .sheet(item: $sheetLandmark) { landmark in
            NavigationStack {
                LandmarkDetailView(landmark: landmark)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                sheetLandmark = nil
                            }
                        }
                    }
            }
        }
        .fullScreenCover(item: $fullScreenLandmark) { landmark in
            NavigationStack {
                LandmarkDetailView(landmark: landmark)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                fullScreenLandmark = nil
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeepLinksView()
    }
    .environment(Navigator())
}
