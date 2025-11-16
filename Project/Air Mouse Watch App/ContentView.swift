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
            VStack {
                Text("Air Mouse")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.top, 10)

                Spacer()

                VStack(spacing: 8) {
                    NavigationLink(destination:
                        StartPage()
                            .environmentObject(accel)
                            .environmentObject(watchSession)
                    ) {
                        NavigationButton(title: "Start", buttonColor: Color("Blue"))
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination:
                        SettingsPage()
                            .environmentObject(accel)
                    ) {
                        NavigationButton(title: "Settings", buttonColor: Color("Gray"))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Provide session globally
        .environmentObject(watchSession)
    }
}

#Preview {
    ContentView()
}
