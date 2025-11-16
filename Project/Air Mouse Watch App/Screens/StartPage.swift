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
                
                // MARK: - Swipe Detection Card
                ZStack {
                    // Breathing circle when no swipe detected
                    if !accel.detectedSwipeLeft &&
                       !accel.detectedSwipeRight &&
                       !accel.detectedSwipeUp &&
                       !accel.detectedSwipeDown {
                        
                        BreathingCircle()
                            .frame(width: 60, height: 60)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Swipe animations
                    if accel.detectedSwipeLeft {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                            .transition(.move(edge: .leading))
                            .animation(.easeOut(duration: 0.4), value: accel.detectedSwipeLeft)
                    }
                    
                    if accel.detectedSwipeRight {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .transition(.move(edge: .trailing))
                            .animation(.easeOut(duration: 0.4), value: accel.detectedSwipeRight)
                    }
                    
                    if accel.detectedSwipeUp {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                            .transition(.move(edge: .top))
                            .animation(.easeOut(duration: 0.4), value: accel.detectedSwipeUp)
                    }
                    
                    if accel.detectedSwipeDown {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .transition(.move(edge: .bottom))
                            .animation(.easeOut(duration: 0.4), value: accel.detectedSwipeDown)
                    }
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
                
                // MARK: - Swipe Handling using modern onChange
                .onChange(of: accel.detectedSwipeLeft) { _, newValue in
                    if newValue { watchSession.sendGesture(.leftSwipe) }
                }
                .onChange(of: accel.detectedSwipeRight) { _, newValue in
                    if newValue { watchSession.sendGesture(.rightSwipe) }
                }
                .onChange(of: accel.detectedSwipeUp) { _, newValue in
                    if newValue { watchSession.sendGesture(.upSwipe) }
                }
                .onChange(of: accel.detectedSwipeDown) { _, newValue in
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
