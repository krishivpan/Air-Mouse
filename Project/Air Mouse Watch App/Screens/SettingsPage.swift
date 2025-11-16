//
//  SettingsPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct SettingsPage: View {
    // State for toggles (UI only, not connected to functionality yet)
    @State private var detectLeftSwipe = true
    @State private var detectRightSwipe = true
    @State private var detectUpSwipe = true
    @State private var detectDownSwipe = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Gesture Detection")
                    .font(.headline)
                    .foregroundColor(.primary)) {

                    Toggle("Detect Left Swipe", isOn: $detectLeftSwipe)
                        .toggleStyle(SwitchToggleStyle(tint: .green))

                    Toggle("Detect Right Swipe", isOn: $detectRightSwipe)
                        .toggleStyle(SwitchToggleStyle(tint: .green))

                    Toggle("Detect Up Swipe", isOn: $detectUpSwipe)
                        .toggleStyle(SwitchToggleStyle(tint: .green))

                    Toggle("Detect Down Swipe", isOn: $detectDownSwipe)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsPage()
}
