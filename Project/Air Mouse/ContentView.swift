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
        VStack {
            Text("Last gesture: \(phoneSession.lastGesture?.rawValue ?? "none")")
            // Rest of your UI
        }
    }
}

// IMPORTANT: provide the environmentObject in Preview, or preview will crash
#Preview {
    ContentView()
        .environmentObject(PhoneSessionManager.shared)
}
