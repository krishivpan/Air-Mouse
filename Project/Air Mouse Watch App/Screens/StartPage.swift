//
//  StartPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI
import WatchKit
import Combine

final class ExtendedRuntimeController: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate {

    @Published var isRunning: Bool = false
    @Published var lastError: Error?

    private var session: WKExtendedRuntimeSession?

    func startSession() {
        if session == nil {
            let newSession = WKExtendedRuntimeSession()
            newSession.delegate = self
            session = newSession
        }
        guard let session = session else { return }
        if session.state == .running { return }
        session.start()
    }

    func endSession() {
        session?.invalidate()
    }

    func extendedRuntimeSessionDidStart(_ session: WKExtendedRuntimeSession) {
        DispatchQueue.main.async {
            self.isRunning = true
            self.lastError = nil
        }
    }

    func extendedRuntimeSessionWillExpire(_ session: WKExtendedRuntimeSession) {}

    func extendedRuntimeSession(
        _ session: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isRunning = false
            self.lastError = error
            if self.session === session { self.session = nil }
        }
    }
}

struct StartPage: View {
    @EnvironmentObject private var watchSession: WatchSessionManager
    @StateObject private var accel = AccelerometerManager()
    @StateObject private var runtimeController = ExtendedRuntimeController()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Header Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gestures")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(Color("Text"))
                        .onTapGesture { watchSession.sendGesture(.tap) }

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
                        .fill(Color("Background"))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )

                // MARK: Gesture Detection Card with smooth animation
                ZStack {
                    // Breathing circle
                    BreathingCircle()
                        .frame(width: 60, height: 60)
                        .opacity(accel.detectedSwipeLeft || accel.detectedSwipeRight || accel.detectedSwipeUp || accel.detectedSwipeDown ? 0 : 1)
                        .scaleEffect(accel.detectedSwipeLeft || accel.detectedSwipeRight || accel.detectedSwipeUp || accel.detectedSwipeDown ? 0.8 : 1)
                        .animation(.easeInOut(duration: 0.3), value: accel.detectedSwipeLeft || accel.detectedSwipeRight || accel.detectedSwipeUp || accel.detectedSwipeDown)

                    // Swipe arrows
                    if accel.detectedSwipeLeft {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .opacity))
                    }
                    if accel.detectedSwipeRight {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .opacity))
                    }
                    if accel.detectedSwipeUp {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .opacity))
                    }
                    if accel.detectedSwipeDown {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("Background"))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
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
        .onAppear {
            accel.start()
            runtimeController.startSession()
        }
        .onDisappear {
            accel.stop()
            runtimeController.endSession()
        }
    }
}

#Preview { StartPage() .environmentObject(WatchSessionManager.shared) }
