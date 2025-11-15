//
//  WatchSessionManager.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import Foundation
import WatchConnectivity
import Combine

// Singleton object that manages the WCSession on the Watch
final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    @Published var isReachable: Bool = false

    private override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // Call this from your UI when you detect the "tap"/clench/etc.
    func sendTapGesture() {
        let session = WCSession.default

        guard session.isReachable else {
            print("iPhone is not reachable")
            return
        }

        let message: [String: Any] = [
            "gesture": "tap"        // you can change this to “clench”, etc.
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("Watch session activation failed: \(error.localizedDescription)")
        } else {
            print("Watch session activated with state: \(activationState.rawValue)")
        }

        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
}
