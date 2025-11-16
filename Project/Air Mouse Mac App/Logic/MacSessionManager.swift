//
//  MacSessionManager.swift
//  Air Mouse Mac
//

import Foundation
import MultipeerConnectivity
import Combine

final class MacSessionManager: NSObject, ObservableObject {

    // Published for the Mac UI
    @Published var isPhoneConnected: Bool = false
    @Published var lastGesture: AirMouseGesture?

    private let serviceType = "airmouse-ctrl" // must match iOS
    private let peerID: MCPeerID
    private var mcSession: MCSession!
    private var browser: MCNearbyServiceBrowser!

    override init() {
        // Show machine name on the other side
        let displayName = Host.current().localizedName ?? "Mac"
        self.peerID = MCPeerID(displayName: displayName)
        super.init()

        setupMultipeer()
    }

    private func setupMultipeer() {
        mcSession = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        mcSession.delegate = self

        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()

        print("Mac: started browsing for iPhone peers")
    }
}

// MARK: - MCSessionDelegate

extension MacSessionManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Mac: peer \(peerID.displayName) state changed: \(state.rawValue)")
        DispatchQueue.main.async {
            self.isPhoneConnected = (state == .connected)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Decode gesture payload from iPhone
        do {
            let payload = try JSONDecoder().decode([String: String].self, from: data)
            if let gestureString = payload[AirMouseKey.gesture],
               let gesture = AirMouseGesture(rawValue: gestureString) {
                DispatchQueue.main.async {
                    self.lastGesture = gesture
                }
                print("Mac: received gesture \(gesture.rawValue)")
            }
        } catch {
            print("Mac: failed to decode data from iPhone: \(error.localizedDescription)")
        }
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // Not used
    }

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // Not used
    }

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // Not used
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MacSessionManager: MCNearbyServiceBrowserDelegate {

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        print("Mac: found peer \(peerID.displayName), inviting...")

        browser.invitePeer(
            peerID,
            to: mcSession,
            withContext: nil,
            timeout: 15
        )
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Mac: lost peer \(peerID.displayName)")
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        print("Mac: failed to start browsing: \(error.localizedDescription)")
    }
}
