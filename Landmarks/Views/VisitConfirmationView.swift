//
//  VisitConfirmationView.swift
//  Landmarks
//

import SwiftUI

/// Demonstrates the pop-to-root pattern.
/// This view receives a path binding and can clear it to return to root.
struct VisitConfirmationView: View {
    let landmark: Landmark
    @Binding var path: [Screen]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Visit Scheduled!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("You're all set to visit \(landmark.name).")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Done button - pops to root
            Button {
                path = []  // Pop to root
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle("Confirmation")
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    @Previewable @State var path: [Screen] = []

    NavigationStack {
        VisitConfirmationView(
            landmark: Landmark.sampleData[0],
            path: $path
        )
    }
}
