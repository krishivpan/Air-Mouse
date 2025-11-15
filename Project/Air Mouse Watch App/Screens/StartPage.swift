//
//  StartPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct StartPage: View {
    @StateObject private var watchSession = WatchSessionManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack {
                Text("Gestures")
                    .font(.title2)
                    .foregroundColor(Color("Text"))
                if watchSession.isReachable {
                    Text("Connected to iPhone")
                        .font(.footnote)
                        .foregroundColor(Color("Green"))
                } else {
                    Text("Not Connected to iPhone")
                        .font(.footnote)
                        .foregroundColor(Color("Red"))
                }

                Spacer().frame(height: 20) // Spacing before buttons
            }
            
            HStack {
                GestureButton(title: "Click Me", action: {watchSession.sendGesture(.tap) })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}


#Preview {
    StartPage()
}

