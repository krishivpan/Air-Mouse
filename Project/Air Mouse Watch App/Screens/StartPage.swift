//
//  StartPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct StartPage: View {
    @StateObject private var watchSession = WatchSessionManager.shared
    @State private var isConnected = false;
    @StateObject private var accel = AccelerometerManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack {
                Text("Gestures")
                    .font(.title2)
                    .foregroundColor(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                
                HStack(spacing: 6) {
                    // Circle indicator
                    Image(systemName: watchSession.isReachable ? "circle.fill" : "circle")
                        .foregroundColor(watchSession.isReachable ? Color.green : Color.red)
                        .font(.system(size: 10))
                    
                    // Status text
                    Text(watchSession.isReachable ? "Connected to iPhone" : "No Connection")
                        .font(.footnote)
                        .foregroundColor(watchSession.isReachable ? Color("Green") : .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(height: 20)
            }
            
            VStack {
                Text("Swipe left to trigger gesture")
                    .padding()
                
                if accel.detectedSwipeLeft {
                    Text("Swipe Left Detected!")
                        .foregroundColor(.green)
                } else {
                    Text("Waiting for swipe...")
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                accel.start()
            }
            .onDisappear {
                accel.stop()
            }
            
//            HStack {
//                GestureButton(title: "Click Me", action: {watchSession.sendGesture(.tap) })
//            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}


#Preview {
    StartPage()
}

