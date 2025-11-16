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
    private let serviceType = "airmouse"   // MUST match iPhone
    private let myPeerID: MCPeerID
    private let session: MCSession
    private let browser: MCNearbyServiceBrowser

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

        session.delegate = self
        browser.delegate = self
        browser.startBrowsingForPeers()
        print("[MacConnection] Started browsing for iPhone peers.")
    }

    deinit {
        browser.stopBrowsingForPeers()
        session.disconnect()
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MacSessionManager: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        print("[MacConnection] Found peer: \(peerID.displayName), inviting...")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        print("[MacConnection] Lost peer: \(peerID.displayName)")
    }

    // Optional (not needed but exists in protocol)
    func browser(_ browser: MCNearbyServiceBrowser,
                 didNotStartBrowsingForPeers error: Error) {
        print("[MacConnection] Failed to start browsing: \(error.localizedDescription)")
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
                print("[MacConnection] Connected to \(peerID.displayName)")
            case .connecting:
                print("[MacConnection] Connecting to \(peerID.displayName)...")
            case .notConnected:
                print("[MacConnection] Disconnected from \(peerID.displayName)")
                self.isConnected = false
                self.connectedPeerName = nil
                self.lastGesture = nil
            @unknown default:
                break
            }
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
            print("[MacConnection] Received data but could not parse gesture.")
            return
        }

        DispatchQueue.main.async {
            self.lastGesture = gesture
            print("[MacConnection] Received gesture: \(gesture.rawValue)")
        }
    }

    // We don't use streams or resources, but must implement the protocol:

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        // Not used
    }

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        // Not used
    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        // Not used
    }
}
