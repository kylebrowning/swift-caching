//
//  EditLandmarkView.swift
//  Landmarks
//

import SwiftUI

/// Demonstrates the "alert before navigation" pattern.
/// Shows a confirmation dialog when the user tries to leave with unsaved changes.
struct EditLandmarkView: View {
    let landmark: Landmark
    @Binding var path: [Screen]

    @State private var name: String = ""
    @State private var location: String = ""
    @State private var showDiscardAlert = false
    @Environment(\.dismiss) private var dismiss

    var hasChanges: Bool {
        name != landmark.name || location != landmark.location
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Location", text: $location)
            }

            Section {
                Text("Try making changes, then tap Back or Done to see the discard confirmation.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Edit Landmark")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    handleDismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    // In a real app, save changes here
                    path = []
                }
                .disabled(!hasChanges)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            name = landmark.name
            location = landmark.location
        }
        .alert("Discard Changes?", isPresented: $showDiscardAlert) {
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("You have unsaved changes that will be lost.")
        }
    }

    private func handleDismiss() {
        if hasChanges {
            showDiscardAlert = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var path: [Screen] = []

    NavigationStack {
        EditLandmarkView(
            landmark: Landmark.sampleData[0],
            path: $path
        )
    }
}
