//
//  PhoneSessionManager.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import Foundation
import WatchConnectivity
import Combine

final class PhoneSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = PhoneSessionManager()

    // Last gesture received from the Watch
    @Published var lastGesture: AirMouseGesture?

    // True when the Watch app is reachable via WCSession (i.e. app in foreground)
    @Published var isReachable: Bool = false

    // For now this is a dummy flag, you’ll flip it from your Mac-connection code later
    @Published var isMacConnected: Bool = false

    private override init() {
        super.init()
        activateSession()
    }

    // MARK: - Session Setup

    private func activateSession() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Public API (for future Mac connection)

    func setMacConnected(_ connected: Bool) {
        DispatchQueue.main.async {
            self.isMacConnected = connected
        }
    }

    // MARK: - WCSessionDelegate

    // This is mainly used on watchOS, but including it here is harmless
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("Phone session activation failed: \(error.localizedDescription)")
        } else {
            print("Phone session activated with state: \(activationState.rawValue)")
        }

        // Update reachability when activation finishes
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Not usually important for basic message passing
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate the default session
        WCSession.default.activate()
    }

    // Called when the reachability of the counterpart app changes
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("Reachability changed. isReachable = \(session.isReachable)")
        }
    }

    // Optional: on iOS, this can tell you about watch pairing / install changes
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("Watch state changed: paired=\(session.isPaired), installed=\(session.isWatchAppInstalled)")
    }

    // Message from Watch → iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from Watch: \(message)")

        guard
            let gestureString = message[AirMouseKey.gesture] as? String,
            let gesture = AirMouseGesture(rawValue: gestureString)
        else { return }

        DispatchQueue.main.async {
            self.lastGesture = gesture
            // Later: forward this to Mac / MouseController
            // MouseController.shared.handleGesture(gesture)
        }
    }
}
