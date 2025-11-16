//
//  MacSessionManager.swift
//  Air Mouse Mac
//
//  Created by You on 2025-11-16.
//

import Foundation
import MultipeerConnectivity
import Combine

final class MacSessionManager: NSObject, ObservableObject {

    static let shared = MacSessionManager()

    // Published state for UI
    @Published var isConnected: Bool = false
    @Published var connectedPeerName: String?
    @Published var lastGesture: AirMouseGesture?

    // Multipeer
    private let serviceType = "airmouse-gest"   // MUST match iPhone
    private let myPeerID: MCPeerID
    private let session: MCSession
    private let browser: MCNearbyServiceBrowser

    private let debugLogPrefix = "[Mac⇄Phone][MC]"

    private override init() {
        // Display name of this Mac in the session
        let hostName = Host.current().localizedName ?? "Mac"
        self.myPeerID = MCPeerID(displayName: hostName)

        self.session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        self.browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceType
        )

        super.init()

        log("INIT with peerID = \(hostName), serviceType = \(serviceType)")

        session.delegate = self
        browser.delegate = self

        browser.startBrowsingForPeers()
        log("Started browsing for iPhone peers.")
    }

    deinit {
        browser.stopBrowsingForPeers()
        session.disconnect()
        log("Deinit: stopped browsing and disconnected session.")
    }

    private func log(_ message: String) {
        print("\(debugLogPrefix) \(message)")
    }

    private func logPeers(_ whereFrom: String) {
        let names = session.connectedPeers.map { $0.displayName }
        print("\(debugLogPrefix) \(whereFrom) – connectedPeers = \(names)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MacSessionManager: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        log("FOUND peer: \(peerID.displayName), inviting...")
        logPeers("before invite")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        log("LOST peer: \(peerID.displayName)")
        logPeers("after lostPeer")
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 didNotStartBrowsingForPeers error: Error) {
        log("❌ Failed to start browsing: \(error.localizedDescription)")
    }
}

// MARK: - MCSessionDelegate

extension MacSessionManager: MCSessionDelegate {

    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.connectedPeerName = peerID.displayName
                self.log("🟢 didChange state = CONNECTED to \(peerID.displayName)")
            case .connecting:
                self.log("🟡 didChange state = CONNECTING to \(peerID.displayName)")
            case .notConnected:
                self.log("🔴 didChange state = NOT CONNECTED to \(peerID.displayName)")
                self.isConnected = false
                self.connectedPeerName = nil
                self.lastGesture = nil
            @unknown default:
                self.log("⚠️ didChange state = UNKNOWN for \(peerID.displayName)")
            }

            self.logPeers("didChange state")
        }
    }

    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        // Expect a JSON dictionary: ["gesture": "<rawValue>"]
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let gestureString = json[AirMouseKey.gesture] as? String,
            let gesture = AirMouseGesture(rawValue: gestureString)
        else {
            log("Received DATA from \(peerID.displayName) but could not parse gesture. Size = \(data.count) bytes")
            return
        }

        DispatchQueue.main.async {
            self.lastGesture = gesture
            self.log("✅ Received gesture from \(peerID.displayName): \(gesture.rawValue)")
        }
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
