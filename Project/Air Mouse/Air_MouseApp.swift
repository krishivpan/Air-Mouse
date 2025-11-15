//
//  Air_MouseApp.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI

@main
struct Air_MouseApp: App {
    @StateObject private var sessionManager = PhoneSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}
