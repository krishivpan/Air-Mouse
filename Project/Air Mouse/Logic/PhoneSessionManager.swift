//
//  PhoneSessionManager.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-15.
//

import Foundation
import WatchConnectivity
import Combine
import MultipeerConnectivity
import UIKit

final class PhoneSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = PhoneSessionManager()

    // Last gesture received from the Watch
    @Published var lastGesture: AirMouseGesture?

    // True when the Watch app is reachable via WCSession (foreground)
    @Published var isReachable: Bool = false

    // True when connected to a Mac via MultipeerConnectivity
    @Published var isMacConnected: Bool = false

    // MARK: - MultipeerConnectivity (iPhone ↔︎ Mac)

    private let serviceType = "airmouse"    // MUST match Mac
    private let myPeerID: MCPeerID
    private let mcSession: MCSession
    private let advertiser: MCNearbyServiceAdvertiser

    private override init() {
        // Multipeer setup
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)

        self.mcSession = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        self.advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )

        super.init()

        // Multipeer delegates
        mcSession.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        print("[Phone→Mac] Started advertising for Mac peers.")

        // WatchConnectivity
        activateSession()
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        mcSession.disconnect()
    }

    // MARK: - WCSession Setup

    private func activateSession() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Send Gesture to Mac

    private func sendGestureToMac(_ gesture: AirMouseGesture) {
        guard !mcSession.connectedPeers.isEmpty else {
            print("[Phone→Mac] No connected Mac peers, cannot send gesture.")
            return
        }

        let payload: [String: Any] = [
            AirMouseKey.gesture: gesture.rawValue
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("[Phone→Mac] Failed to encode gesture payload.")
            return
        }

        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            print("[Phone→Mac] Sent gesture: \(gesture.rawValue)")
        } catch {
            print("[Phone→Mac] Failed to send gesture: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Handle Gesture (common handler)
    
    private func handleGesture(_ gesture: AirMouseGesture) {
        DispatchQueue.main.async {
            self.lastGesture = gesture
            // 🔁 FORWARD TO MAC
            self.sendGestureToMac(gesture)
        }
    }

    // MARK: - WCSessionDelegate (Watch → iPhone)

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

        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("Reachability changed. isReachable = \(session.isReachable)")
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        print("Watch state changed: paired=\(session.isPaired), installed=\(session.isWatchAppInstalled)")
    }

    // WATCH → PHONE gesture message (when watch is awake and reachable)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from Watch: \(message)")

        guard
            let gestureString = message[AirMouseKey.gesture] as? String,
            let gesture = AirMouseGesture(rawValue: gestureString)
        else { return }

        handleGesture(gesture)
    }
    
    // WATCH → PHONE gesture via transferUserInfo (when watch screen is off/suspended)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        print("Received userInfo from Watch: \(userInfo)")
        
        guard
            let gestureString = userInfo[AirMouseKey.gesture] as? String,
            let gesture = AirMouseGesture(rawValue: gestureString)
        else { return }
        
        handleGesture(gesture)
    }
}

// MARK: - MCSessionDelegate (iPhone ↔︎ Mac)

extension PhoneSessionManager: MCSessionDelegate {

    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isMacConnected = true
                print("[Phone→Mac] Connected to Mac: \(peerID.displayName)")
            case .connecting:
                print("[Phone→Mac] Connecting to Mac: \(peerID.displayName)...")
            case .notConnected:
                self.isMacConnected = false
                print("[Phone→Mac] Disconnected from Mac: \(peerID.displayName)")
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        // Not used (Mac does not send gestures back)
        print("[Phone→Mac] Received data from Mac (unused).")
    }

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {}

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension PhoneSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        print("[Phone→Mac] Received invitation from Mac: \(peerID.displayName), accepting.")
        invitationHandler(true, mcSession)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {
        print("[Phone→Mac] Failed to start advertising: \(error.localizedDescription)")
    }
}
