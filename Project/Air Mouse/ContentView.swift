//
//  ContentView.swift
//  Air Mouse (iOS)
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI
import UIKit   // for opening Settings app

struct ContentView: View {
    @EnvironmentObject private var phoneSession: PhoneSessionManager.shared
    @State private var showSettingsAlert: Bool = false

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

                    // MARK: - Debug Info
                    debugInfoSection

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
                    isConnected: phoneSession.isMacConnected,
                    iconName: "laptopcomputer"
                )
            }

            // Settings button (simple + compact)
            HStack {
                Button(action: {
                    showSettingsAlert = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                        Text("Open Settings")
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

                Spacer()
            }
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
        // Alert to open Settings
        .alert("Open Settings?", isPresented: $showSettingsAlert) {
            Button("Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You’ll be taken to the iOS Settings app.")
        }
    }

    func connectionRow(label: String, isConnected: Bool, iconName: String) -> some View {
        HStack {
            HStack(spacing: 8) {

                Image(systemName: iconName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(width: 22, alignment: .leading)
                    .offset(x: iconName == "laptopcomputer" ? -3 : 0)

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

                        // Simple “live” indicator
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

    // Extra debug section
    var debugInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug Info (iOS)")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Watch reachable: \(phoneSession.isReachable.description)")
                .font(.caption2)
                .foregroundColor(.gray)

            Text("Mac connected: \(phoneSession.isMacConnected.description)")
                .font(.caption2)
                .foregroundColor(.gray)

            if let gesture = phoneSession.lastGesture {
                Text("Last gesture: \(gesture.rawValue)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                Text("Last gesture: nil")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }

    func prettyGestureName(_ gesture: AirMouseGesture?) -> String {
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

    // Opens the app’s Settings page in the iOS Settings app
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:]) { success in
                print("📱[ContentView] Settings opened: \(success)")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(PhoneSessionManager.shared)
}
