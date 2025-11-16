//
//  StartPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct StartPage: View {
    @EnvironmentObject private var watchSession: WatchSessionManager
    @StateObject private var accel = AccelerometerManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Header Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gestures")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(Color("Text"))
                        .onTapGesture {
                            watchSession.sendGesture(.tap)
                        }
                    
                    HStack(spacing: 8) {
                        Image(systemName: watchSession.isReachable ? "circle.fill" : "circle")
                            .foregroundColor(watchSession.isReachable ? .green : .red)
                            .font(.system(size: 12))
                        
                        Text(watchSession.isReachable ? "Connected to iPhone" : "No Connection")
                            .font(.footnote)
                            .foregroundColor(
                                watchSession.isReachable ? Color("Green") : .red
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardBackground"))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // MARK: - Gesture Detection Card
                ZStack {
                    // Show breathing circle when no swipe is detected
                    if !accel.detectedSwipeLeft &&
                        !accel.detectedSwipeRight &&
                        !accel.detectedSwipeUp &&
                        !accel.detectedSwipeDown {
                        
                        BreathingCircle()
                            .frame(width: 60, height: 60)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Show detected gesture indicators
                    VStack(spacing: 4) {
                        if accel.detectedSwipeLeft {
                            HStack {
                                Image(systemName: "arrow.left.circle.fill")
                                    .foregroundColor(.green)
                                Text("Left Swipe Detected")
                                    .foregroundColor(Color("Text"))
                            }
                        }
                        if accel.detectedSwipeRight {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Right Swipe Detected")
                                    .foregroundColor(Color("Text"))
                            }
                        }
                        if accel.detectedSwipeUp {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Up Swipe Detected")
                                    .foregroundColor(Color("Text"))
                            }
                        }
                        if accel.detectedSwipeDown {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(.red)
                                Text("Down Swipe Detected")
                                    .foregroundColor(Color("Text"))
                            }
                        }
                    }
                    .animation(.spring(), value: accel.detectedSwipeLeft)
                    .animation(.spring(), value: accel.detectedSwipeRight)
                    .animation(.spring(), value: accel.detectedSwipeUp)
                    .animation(.spring(), value: accel.detectedSwipeDown)
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardBackground"))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .onAppear { accel.start() }
                .onDisappear { accel.stop() }
                
                // MARK: - Swipe Handling 
                .onChange(of: accel.detectedSwipeLeft) { oldValue, newValue in
                    if newValue { watchSession.sendGesture(.leftSwipe) }
                }
                .onChange(of: accel.detectedSwipeRight) { oldValue, newValue in
                    if newValue { watchSession.sendGesture(.rightSwipe) }
                }
                .onChange(of: accel.detectedSwipeUp) { oldValue, newValue in
                    if newValue { watchSession.sendGesture(.upSwipe) }
                }
                .onChange(of: accel.detectedSwipeDown) { oldValue, newValue in
                    if newValue { watchSession.sendGesture(.downSwipe) }
                }

                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    StartPage()
        .environmentObject(WatchSessionManager.shared)
}
