//
//  ContentView.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var phoneSession: PhoneSessionManager

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Connection Status
            HStack(spacing: 8) {
                Image(systemName: phoneSession.isReachable ? "circle.fill" : "circle")
                    .foregroundColor(phoneSession.isReachable ? .green : .red)
                    .font(.system(size: 14))

                Text(phoneSession.isReachable ? "Watch Connected" : "Watch Not Reachable")
                    .foregroundColor(phoneSession.isReachable ? .green : .red)
                    .font(.headline)
            }

            Divider()
                .padding(.horizontal)

            // MARK: - Last Gesture
            VStack(spacing: 8) {
                Text("Last Gesture:")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text(phoneSession.lastGesture?.rawValue.capitalized ?? "None")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(PhoneSessionManager.shared)
}

