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

    @Published var lastGesture: AirMouseGesture?    // ⬅️ use the enum

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

    // MARK: - WCSessionDelegate

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
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from Watch: \(message)")

        // ⬇️ use the shared key + convert to enum
        guard
            let gestureString = message[AirMouseKey.gesture] as? String,
            let gesture = AirMouseGesture(rawValue: gestureString)
        else { return }

        DispatchQueue.main.async {
            self.lastGesture = gesture
            // MouseController.shared.handleGesture(gesture)
        }
    }
}
