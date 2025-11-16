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

    private let serviceType = "airmouse-gest"    // MUST match Mac
    private let myPeerID: MCPeerID
    private let mcSession: MCSession
    private let advertiser: MCNearbyServiceAdvertiser

    private let debugLogPrefix = "[Phone→Mac][MC]"

    private override init() {
        // Multipeer setup
        let deviceName = UIDevice.current.name
        self.myPeerID = MCPeerID(displayName: deviceName)

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

        log("INIT with peerID = \(deviceName), serviceType = \(serviceType)")

        // Multipeer delegates
        mcSession.delegate = self
        advertiser.delegate = self

        advertiser.startAdvertisingPeer()
        log("Started advertising for Mac peers.")

        // WatchConnectivity
        activateSession()
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        mcSession.disconnect()
        log("Deinit: stopped advertising and disconnected session.")
    }

    private func log(_ message: String) {
        print("\(debugLogPrefix) \(message)")
    }

    private func logPeers(_ whereFrom: String) {
        let names = mcSession.connectedPeers.map { $0.displayName }
        print("\(debugLogPrefix) \(whereFrom) – connectedPeers = \(names)")
    }

    // MARK: - WCSession Setup

    private func activateSession() {
        guard WCSession.isSupported() else {
            print("[Phone→Watch] WCSession is not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("[Phone→Watch] Activating WCSession...")
    }

    // MARK: - Send Gesture to Mac

    private func sendGestureToMac(_ gesture: AirMouseGesture) {
        logPeers("sendGestureToMac BEFORE send")

        guard !mcSession.connectedPeers.isEmpty else {
            log("No connected Mac peers, CANNOT send gesture \(gesture.rawValue).")
            return
        }

        let payload: [String: Any] = [
            AirMouseKey.gesture: gesture.rawValue
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            log("Failed to encode gesture payload \(gesture.rawValue).")
            return
        }

        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
            log("✅ Sent gesture: \(gesture.rawValue)")
        } catch {
            log("❌ Failed to send gesture \(gesture.rawValue): \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate (Watch → iPhone)

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("[Phone→Watch] activation failed: \(error.localizedDescription)")
        } else {
            print("[Phone→Watch] activation state: \(activationState.rawValue)")
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
            print("[Phone→Watch] Reachability changed. isReachable = \(session.isReachable)")
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        print("[Phone→Watch] Watch state changed: paired=\(session.isPaired), installed=\(session.isWatchAppInstalled)")
    }

    // WATCH → PHONE gesture message
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[Phone→Watch] Received message from Watch: \(message)")

        guard
            let gestureString = message[AirMouseKey.gesture] as? String,
            let gesture = AirMouseGesture(rawValue: gestureString)
        else {
            print("[Phone→Watch] Could not parse gesture from message.")
            return
        }

        DispatchQueue.main.async {
            self.lastGesture = gesture
            print("[Phone→Watch] Set lastGesture = \(gesture.rawValue)")

            // 🔁 FORWARD TO MAC
            self.sendGestureToMac(gesture)
        }
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
                self.log("🟢 didChange state = CONNECTED to \(peerID.displayName)")
            case .connecting:
                self.log("🟡 didChange state = CONNECTING to \(peerID.displayName)")
            case .notConnected:
                self.isMacConnected = false
                self.log("🔴 didChange state = NOT CONNECTED to \(peerID.displayName)")
            @unknown default:
                self.log("⚠️ didChange state = UNKNOWN for \(peerID.displayName)")
            }

            self.logPeers("didChange state")
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        // Not used (Mac does not send gestures back)
        log("Received DATA from Mac \(peerID.displayName) (unused). Size = \(data.count) bytes")
    }

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        log("Received STREAM \(streamName) from \(peerID.displayName) (unused)")
    }

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        log("Started receiving RESOURCE \(resourceName) from \(peerID.displayName) (unused)")
    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        log("Finished receiving RESOURCE \(resourceName) from \(peerID.displayName) (unused). Error=\(String(describing: error))")
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension PhoneSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        log("INVITE: Received invitation from Mac: \(peerID.displayName). Accepting.")
        logPeers("before accepting invite")
        invitationHandler(true, mcSession)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {
        log("❌ Failed to start advertising: \(error.localizedDescription)")
    }
}
