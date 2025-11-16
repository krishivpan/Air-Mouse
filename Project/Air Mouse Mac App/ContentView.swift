//
//  ContentView.swift
//  Air Mouse Mac
//
//  Created by You on 2025-11-16.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var macConnection = MacSessionManager.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.07, green: 0.07, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Air Mouse – Mac")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Listening for gestures from your iPhone.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Connection status
                connectionStatusSection

                // Gesture feed
                gestureFeedSection

                Spacer()
            }
            .padding(24)
        }
        .frame(minWidth: 420, minHeight: 260)
    }

    // MARK: - Subviews

    private var connectionStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection Status")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 10) {
                Circle()
                    .fill(macConnection.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)

                Text(macConnection.isConnected ? "Connected to iPhone" : "Not Connected")
                    .font(.subheadline)
                    .foregroundColor(macConnection.isConnected ? .green : .red)

                if let peerName = macConnection.connectedPeerName, macConnection.isConnected {
                    Text("(\(peerName))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.18),
                            Color(red: 0.08, green: 0.08, blue: 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var gestureFeedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gesture Feed")
                .font(.headline)
                .foregroundColor(.white)

            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.16, blue: 0.24),
                            Color(red: 0.10, green: 0.10, blue: 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prettyGestureName(macConnection.lastGesture))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Text("Live from iPhone")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                                .frame(width: 42, height: 42)
                            Circle()
                                .fill(Color.blue.opacity(0.9))
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.horizontal, 16)
                )
                .frame(height: 80)
        }
        .padding(.top, 4)
    }

    private func prettyGestureName(_ gesture: AirMouseGesture?) -> String {
        guard let gesture = gesture else { return "Listening for Gestures" }

        switch gesture {
        case .leftSwipe:      return "Left Swipe"
        case .rightSwipe:     return "Right Swipe"
        case .upSwipe:        return "Up Swipe"
        case .downSwipe:      return "Down Swipe"
        case .clockSwipe:     return "Clockwise Swipe"
        case .counterSwipe:   return "Counter-Clockwise Swipe"
        case .tap:            return "Tap"
        case .clench:         return "Clench"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(MacSessionManager.shared)
}
