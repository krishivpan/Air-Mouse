//
//  ContentView.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI
import UIKit   // for opening Settings

struct ContentView: View {
    @EnvironmentObject private var phoneSession: PhoneSessionManager
    @State private var isMacConnected: Bool = false   // dummy Mac connection for now

    var body: some View {
        ZStack {
            // Dark, techy background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.07, green: 0.07, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    headerView

                    // MARK: - Connection Status Card
                    connectionStatusCard

                    // MARK: - Gesture Feed Card
                    gestureFeedCard

                    Spacer(minLength: 16)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Subviews
private extension ContentView {

    var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Air Mouse")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Control your Mac with gestures from your Apple Watch.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    var connectionStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title
            HStack {
                Text("Connection Status")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }

            // Watch + Mac status rows
            VStack(spacing: 10) {
                connectionRow(
                    label: "Watch",
                    isConnected: phoneSession.isReachable,
                    iconName: "applewatch"
                )

                connectionRow(
                    label: "MacBook",
                    isConnected: isMacConnected,
                    iconName: "laptopcomputer"
                )
            }

            // Settings button (simple + compact, label unchanged)
            Button(action: openBluetoothSettings) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.horizontal.circle.fill")
                    Text("Open Bluetooth Settings")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.25))
                )
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
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
                .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
        )
    }

    func connectionRow(label: String, isConnected: Bool, iconName: String) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)

                Text(isConnected ? "Connected" : "Not Connected")
                    .font(.subheadline)
                    .foregroundColor(isConnected ? .green : .red)
            }
        }
    }

    var gestureFeedCard: some View {
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
                            Text(prettyGestureName(phoneSession.lastGesture))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Text("Live from Watch")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // Simple activity indicator
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

    func prettyGestureName(_ gesture: AirMouseGesture?) -> String {
        // More professional default
        guard let gesture = gesture else { return "Awaiting Gesture…" }

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

    func openBluetoothSettings() {
        // Open Settings app (label kept as "Open Bluetooth Settings")
        if let appSettings = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(PhoneSessionManager.shared)
}
