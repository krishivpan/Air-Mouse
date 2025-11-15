//
//  Air_MouseApp.swift
//  Air Mouse Watch App
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI

@main
struct Air_Mouse_Watch_AppApp: App {
    @StateObject private var sessionManager = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}

