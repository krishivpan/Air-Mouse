//
//  ContentView.swift
//  Air Mouse Watch App
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // Welcome text
                Text("Welcome User!")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 8) {
                    // Navigation button
                    NavigationLink(destination: StartPage()) {
                        NavigationButton(title: "Start", buttonColor: Color("Blue"))
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: SettingsPage()) {
                        NavigationButton(title: "Settings", buttonColor: Color("Purple"))
                    }
                    .buttonStyle(.plain)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
