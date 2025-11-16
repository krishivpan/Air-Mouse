//
//  ContentView.swift
//  Air Mouse Watch App
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var accel = AccelerometerManager()
    @StateObject private var watchSession = WatchSessionManager.shared

    var body: some View {
        NavigationStack {
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

                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Header
                    headerView
                    
                    Spacer()
                    
                    // MARK: - Navigation Cards
                    navigationCards
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .preferredColorScheme(.dark)
            // Provide session globally
            .environmentObject(watchSession)
        }
    }
}

// MARK: - Subviews
private extension ContentView {
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Air Mouse")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Control with gestures")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    var navigationCards: some View {
        VStack(spacing: 10) {
            // Start Button Card
            NavigationLink(destination:
                StartPage()
                    .environmentObject(accel)
                    .environmentObject(watchSession)
            ) {
                navigationCard(
                    title: "Start",
                    icon: "play.fill",
                    colors: [Color.blue, Color.blue.opacity(0.7)]
                )
            }
            .buttonStyle(.plain)
            
            // Settings Button Card
            NavigationLink(destination:
                SettingsPage()
                    .environmentObject(accel)
            ) {
                navigationCard(
                    title: "Settings",
                    icon: "gearshape.fill",
                    colors: [Color.purple, Color.purple.opacity(0.7)]
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    func navigationCard(title: String, icon: String, colors: [Color]) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: colors[0].opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    ContentView()
}
