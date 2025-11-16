//
//  Air_Mouse_MacApp.swift
//  Air Mouse Mac
//

import SwiftUI

@main
struct Air_Mouse_MacApp: App {
    @StateObject private var macSession = MacSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(macSession)
        }
    }
}
