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
    
    private var messageQueue: [[String: Any]] = []
    private var reconnectTimer: Timer?

    private override init() {
        super.init()
        activateSession()
        startReconnectTimer()
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
    
    private func startReconnectTimer() {
        // Periodically check and maintain connection
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.maintainConnection()
        }
    }
    
    private func maintainConnection() {
        let session = WCSession.default
        
        // Update reachability status
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        
        // Try to send queued messages if connection is restored
        if session.isReachable && !messageQueue.isEmpty {
            print("Connection restored, sending \(messageQueue.count) queued messages")
            let queue = messageQueue
            messageQueue.removeAll()
            
            for message in queue {
                sendMessageNow(message)
            }
        }
    }

    // Call this from your UI when you detect the "tap"/clench/etc.
    func sendGesture(_ gesture: AirMouseGesture) {
        let message: [String: Any] = [
            AirMouseKey.gesture: gesture.rawValue
        ]
        
        let session = WCSession.default

        if session.isReachable {
            sendMessageNow(message)
        } else {
            // Queue the message and try to send via transferUserInfo as backup
            print("iPhone not reachable, queuing message and using transferUserInfo")
            messageQueue.append(message)
            
            // Use transferUserInfo as a backup - it works even when not reachable
            session.transferUserInfo(message)
        }
    }
    
    private func sendMessageNow(_ message: [String: Any]) {
        let session = WCSession.default
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending gesture: \(error.localizedDescription)")
            // If send fails, try transferUserInfo as backup
            session.transferUserInfo(message)
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
        print("Session reachability changed to: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        
        // Try to send queued messages when connection is restored
        if session.isReachable {
            maintainConnection()
        }
    }
}
