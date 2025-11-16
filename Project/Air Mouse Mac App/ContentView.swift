//
//  ContentView.swift
//  Air Mouse Mac
//
//  Created by You on 2025-11-16.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var macConnection = MacSessionManager.shared
    @StateObject private var macroManager = GestureMacroManager.shared

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.07, green: 0.07, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView {
                DashboardView(macConnection: macConnection)
                    .tabItem {
                        Label("Dashboard", systemImage: "waveform")
                    }

                MacroSettingsView(macroManager: macroManager)
                    .tabItem {
                        Label("Gestures & Macros", systemImage: "slider.horizontal.3")
                    }
            }
            .accentColor(.cyan)
            .padding(.top, 4) // small breathing room
        }
        .frame(minWidth: 560, minHeight: 360)
    }
}

// MARK: - Dashboard

private struct DashboardView: View {
    @ObservedObject var macConnection: MacSessionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {

            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Air Mouse – Mac")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Runs quietly in the background, translating Watch gestures into Mac shortcuts.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Connection + current gesture in a grid
            HStack(alignment: .top, spacing: 16) {
                connectionStatusCard
                currentGestureCard
            }

            Spacer()
        }
        .padding(24)
    }

    private var connectionStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Connection Status", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }

            HStack(spacing: 10) {
                Circle()
                    .fill(macConnection.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(macConnection.isConnected ? "Connected to iPhone" : "Not Connected")
                        .font(.subheadline)
                        .foregroundColor(macConnection.isConnected ? .green : .red)

                    if let peerName = macConnection.connectedPeerName, macConnection.isConnected {
                        Text(peerName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }

            Text("Leave this app running while you use your Mac. Gestures from your Watch → iPhone will be translated into key presses and clicks.")
                .font(.caption)
                .foregroundColor(.gray)
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
                .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 10)
        )
    }

    private var currentGestureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Gesture")
                .font(.headline)
                .foregroundColor(.white)

            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.18, blue: 0.26),
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

                        // "live" indicator
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                                .frame(width: 46, height: 46)

                            Circle()
                                .fill(Color.blue.opacity(0.9))
                                .frame(width: 18, height: 18)
                        }
                    }
                    .padding(.horizontal, 16)
                )
                .frame(height: 90)
        }
    }

    private func prettyGestureName(_ gesture: AirMouseGesture?) -> String {
        guard let gesture = gesture else { return "Waiting for Gestures…" }

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

// MARK: - Macro settings

private struct MacroSettingsView: View {
    @ObservedObject var macroManager: GestureMacroManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Gestures & Macros")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("Choose what each gesture does on your Mac — arrow keys, clicks, or nothing.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // List of gesture → macro mappings
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(AirMouseGesture.allCases, id: \.self) { gesture in
                        gestureRow(for: gesture)
                    }

                    HStack {
                        Spacer()
                        Button(role: .destructive) {
                            macroManager.resetToDefaults()
                        } label: {
                            Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func gestureRow(for gesture: AirMouseGesture) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(prettyGestureName(gesture))
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(bindingSubtitle(for: gesture))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Picker("", selection: binding(for: gesture)) {
                ForEach(MacroTarget.allCases) { target in
                    Text(target.displayName).tag(target)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 180)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.14, blue: 0.22),
                            Color(red: 0.10, green: 0.10, blue: 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func binding(for gesture: AirMouseGesture) -> Binding<MacroTarget> {
        Binding(
            get: {
                macroManager.bindings[gesture] ?? .none
            },
            set: { newValue in
                macroManager.setBinding(for: gesture, to: newValue)
            }
        )
    }

    private func prettyGestureName(_ gesture: AirMouseGesture) -> String {
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

    private func bindingSubtitle(for gesture: AirMouseGesture) -> String {
        let target = macroManager.bindings[gesture] ?? .none
        switch target {
        case .none:
            return "This gesture is ignored."
        default:
            return "Triggers: \(target.displayName)"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
