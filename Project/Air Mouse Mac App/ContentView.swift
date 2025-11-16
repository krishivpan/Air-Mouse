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
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.05),
                    Color(red: 0.05, green: 0.05, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView {
                DashboardView(macConnection: macConnection)
                    .tabItem {
                        Label("Dashboard", systemImage: "circle.grid.2x2.fill")
                    }

                MacroSettingsView(macroManager: macroManager)
                    .tabItem {
                        Label("Macros", systemImage: "command")
                    }
            }
            .accentColor(.cyan)
        }
        .frame(minWidth: 700, minHeight: 450)
    }
}

// MARK: - Dashboard

private struct DashboardView: View {
    @ObservedObject var macConnection: MacSessionManager

    var body: some View {
        VStack(spacing: 0) {
            // Spacer for top breathing room
            Spacer()
                .frame(height: 60)
            
            // Header
            VStack(spacing: 12) {
                Text("Air Mouse")
                    .font(.system(size: 42, weight: .light, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .kerning(1.2)

                Text("Control your Mac with Apple Watch gestures")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                    .kerning(0.3)
            }
            
            Spacer()
                .frame(height: 50)

            // Status Cards - Horizontal Layout
            HStack(spacing: 20) {
                connectionStatusCard
                gestureFeedCard
            }
            .padding(.horizontal, 80)

            Spacer()
        }
    }

    private var connectionStatusCard: some View {
        VStack(spacing: 0) {
            // Status indicator
            HStack(spacing: 12) {
                Circle()
                    .fill(macConnection.isConnected ?
                          Color.green.opacity(0.9) :
                          Color.white.opacity(0.15))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(macConnection.isConnected ?
                                   Color.green.opacity(0.3) :
                                   Color.white.opacity(0.1),
                                   lineWidth: 8)
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(macConnection.isConnected ? "Connected" : "Searching")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    if let peerName = macConnection.connectedPeerName, macConnection.isConnected {
                        Text(peerName)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    } else {
                        Text("Looking for iPhone...")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var gestureFeedCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Gesture indicator
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 36, height: 36)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 8, height: 8)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(prettyGestureName(macConnection.lastGesture))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("Last gesture")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func prettyGestureName(_ gesture: AirMouseGesture?) -> String {
        guard let gesture = gesture else { return "None" }

        switch gesture {
        case .leftSwipe:      return "Left Swipe"
        case .rightSwipe:     return "Right Swipe"
        case .upSwipe:        return "Up Swipe"
        case .downSwipe:      return "Down Swipe"
        case .clockSwipe:     return "Clockwise"
        case .counterSwipe:   return "Counter-Clockwise"
        case .tap:            return "Tap"
        case .clench:         return "Clench"
        }
    }
}

// MARK: - Macro Settings

private struct MacroSettingsView: View {
    @ObservedObject var macroManager: GestureMacroManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 10) {
                Text("Gesture Macros")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.white)
                    .kerning(0.5)

                Text("Map gestures to keyboard and mouse actions")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            .padding(.bottom, 30)

            // Gesture list
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(AirMouseGesture.allCases, id: \.self) { gesture in
                        gestureRow(for: gesture)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                Button(role: .destructive) {
                    macroManager.resetToDefaults()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11))
                        Text("Reset to Defaults")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }
        }
    }

    private func gestureRow(for gesture: AirMouseGesture) -> some View {
        HStack(spacing: 16) {
            // Gesture name
            Text(prettyGestureName(gesture))
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .regular))
                .frame(width: 140, alignment: .leading)

            Spacer()

            // Action picker
            Picker("", selection: binding(for: gesture)) {
                ForEach(MacroTarget.allCases) { target in
                    Text(target.displayName)
                        .font(.system(size: 12))
                        .tag(target)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 140)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
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
        case .clockSwipe:     return "Clockwise"
        case .counterSwipe:   return "Counter-CW"
        case .tap:            return "Tap"
        case .clench:         return "Clench"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
