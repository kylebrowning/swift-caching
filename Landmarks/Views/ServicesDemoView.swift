//
//  ServicesDemoView.swift
//  Landmarks
//
//  Demonstrates caching behavior - test different policies and see the store update.
//

import SwiftUI

struct ServicesDemoView: View {
    @Environment(\.landmarkService) private var landmarkService
    @Environment(\.analyticsService) private var analytics

    private var store: LandmarkStore { landmarkService.store }

    @State private var selectedPolicy: CachePolicy = .cacheThenFetch

    var body: some View {
        List {
            // Current State Section
            Section("Store State") {
                stateRow("Status", value: stateDescription)
                stateRow("Landmarks", value: "\(store.landmarks.count)")
                stateRow("Data Source", value: store.dataSource.map { "\($0)" } ?? "None")

                if let lastUpdated = store.lastUpdated {
                    stateRow("Last Updated", value: timeAgo(lastUpdated))
                }

                if store.isShowingCachedData {
                    Label("Showing cached data", systemImage: "internaldrive")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if let error = store.loadingState.error {
                    stateRow("Error", value: error.localizedDescription)
                        .foregroundStyle(.red)
                }
            }

            // Cache Policy Section
            Section {
                Picker("Cache Policy", selection: $selectedPolicy) {
                    Text("Cache Then Fetch").tag(CachePolicy.cacheThenFetch)
                    Text("Cache Else Fetch").tag(CachePolicy.cacheElseFetch)
                    Text("Network Only").tag(CachePolicy.networkOnly)
                    Text("Cache Only").tag(CachePolicy.cacheOnly)
                    Text("Network Else Cache").tag(CachePolicy.networkElseCache)
                }
                .pickerStyle(.menu)

                Button {
                    Task {
                        try? await landmarkService.fetchLandmarks(selectedPolicy)
                    }
                } label: {
                    Label("Fetch with Policy", systemImage: "arrow.clockwise")
                }
                .disabled(store.loadingState.isLoading)
            } header: {
                Text("Test Cache Policies")
            } footer: {
                Text(policyDescription)
            }

            // Cache Actions
            Section("Cache Management") {
                Button(role: .destructive) {
                    Task {
                        await landmarkService.clearCache()
                    }
                } label: {
                    Label("Clear Cache", systemImage: "trash")
                }
            }

            // Explanation
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    policyExplanation("Cache Then Fetch",
                        description: "Shows cached data immediately, then fetches fresh data. The store updates twice - you'll see the data source change from 'cache' to 'network'.")

                    policyExplanation("Cache Else Fetch",
                        description: "Uses cache if available, only fetches if cache is empty. Good for detail views where stale data is acceptable.")

                    policyExplanation("Network Only",
                        description: "Always fetches from network, ignores cache. Use after mutations when you need guaranteed fresh data.")

                    policyExplanation("Cache Only",
                        description: "Only uses cached data, never hits network. Perfect for offline mode.")

                    policyExplanation("Network Else Cache",
                        description: "Tries network first, falls back to cache on failure. Good when fresh data is preferred but stale is acceptable.")
                }
            } header: {
                Text("Policy Guide")
            }
        }
        .navigationTitle("Caching Demo")
        .task {
            await analytics.trackScreenView("CachingDemo")
        }
    }

    private var stateDescription: String {
        switch store.loadingState {
        case .idle: return "Idle"
        case .loading: return "Loading..."
        case .loaded: return "Loaded"
        case .failed: return "Failed"
        }
    }

    private var policyDescription: String {
        switch selectedPolicy {
        case .cacheThenFetch:
            return "Show cache immediately, then refresh from network."
        case .cacheElseFetch:
            return "Use cache if available, otherwise fetch."
        case .networkOnly:
            return "Always fetch from network, ignore cache."
        case .cacheOnly:
            return "Only use cached data, no network request."
        case .networkElseCache:
            return "Try network first, fall back to cache on error."
        }
    }

    private func stateRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontDesign(.monospaced)
        }
    }

    private func policyExplanation(_ title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 {
            return "\(seconds)s ago"
        } else if seconds < 3600 {
            return "\(seconds / 60)m ago"
        } else {
            return "\(seconds / 3600)h ago"
        }
    }
}

#Preview {
    NavigationStack {
        ServicesDemoView()
    }
    .services(.preview)
}
