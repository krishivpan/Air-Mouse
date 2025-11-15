//
//  Air_MouseApp.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI

@main
struct Air_MouseApp: App {
    @StateObject private var phoneSession = PhoneSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(phoneSession) // Receives updates from the Phone Session (incoming gestures)
        }
    }
}
