//
//  StartPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct StartPage: View {
    @StateObject private var watchSession = WatchSessionManager.shared
    @StateObject private var accel = AccelerometerManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: Header Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gestures")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(Color("Text"))
                        .onTapGesture { watchSession.sendGesture(.tap)}
                    
                    
                    
                    HStack(spacing: 8) {
                        Image(systemName: watchSession.isReachable ? "circle.fill" : "circle")
                            .foregroundColor(watchSession.isReachable ? .green : .red)
                            .font(.system(size: 12))
                        
                        Text(watchSession.isReachable ? "Connected to iPhone" : "No Connection")
                            .font(.footnote)
                            .foregroundColor(watchSession.isReachable ? Color("Green") : .red)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardBackground")) // Use a light gray/soft color
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // MARK: Swipe Detection Card
                ZStack {
                    // Breathing circle in the background
                    if !accel.detectedSwipeLeft {
                        BreathingCircle()
                            .frame(width: 60, height: 60)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    
                }
                .onAppear { accel.start() }
                .onDisappear { accel.stop() }
                .onChange(of: accel.detectedSwipeLeft) {
                    if accel.detectedSwipeLeft {
                        watchSession.sendGesture(.leftSwipe)
                        print("LEFT SWIPE SENT TO IPHONE")
                    }
                }

                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    StartPage()
}
