//
//  MacSessionManager.swift
//  Air Mouse Mac
//
//  Created by You on 2025-11-16.
//

import Foundation
import MultipeerConnectivity
import Combine
import AppKit   // for CGEvent / mouse & keyboard events

// MARK: - Macro Action Model

/// The type of action that should be performed for a gesture.
/// You can extend this later with more cases (e.g. custom shortcuts, shell scripts, etc.).
enum MacroAction: Equatable, Codable {
    case none
    case keyPress(keyCode: UInt16)
    case leftClick
    case rightClick

    // Codable implementation
    private enum CodingKeys: String, CodingKey {
        case type, keyCode
    }

    private enum ActionType: String, Codable {
        case none
        case keyPress
        case leftClick
        case rightClick
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        switch type {
        case .none:
            self = .none
        case .keyPress:
            let keyCode = try container.decode(UInt16.self, forKey: .keyCode)
            self = .keyPress(keyCode: keyCode)
        case .leftClick:
            self = .leftClick
        case .rightClick:
            self = .rightClick
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .none:
            try container.encode(ActionType.none, forKey: .type)
        case .keyPress(let keyCode):
            try container.encode(ActionType.keyPress, forKey: .type)
            try container.encode(keyCode, forKey: .keyCode)
        case .leftClick:
            try container.encode(ActionType.leftClick, forKey: .type)
        case .rightClick:
            try container.encode(ActionType.rightClick, forKey: .type)
        }
    }
}

// MARK: - MacSessionManager

final class MacSessionManager: NSObject, ObservableObject {

    static let shared = MacSessionManager()

    // Published state for UI
    @Published var isConnected: Bool = false
    @Published var connectedPeerName: String?
    @Published var lastGesture: AirMouseGesture?

    /// Gesture → macro mapping. UI can read + modify this.
    @Published var gestureMappings: [AirMouseGesture: MacroAction] = [:] {
        didSet {
            saveMappings()
        }
    }

    // Multipeer
    private let serviceType = "airmouse"   // MUST match iPhone
    private let myPeerID: MCPeerID
    private let session: MCSession
    private let browser: MCNearbyServiceBrowser

    // Persistence
    private let mappingsDefaultsKey = "AirMouseGestureMappings"

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

        // Load or create default mappings
        loadMappingsIfNeeded()
    }

    deinit {
        browser.stopBrowsingForPeers()
        session.disconnect()
    }

    // MARK: - Public API for UI

    /// Update mapping for a specific gesture (for your future "Macros" settings page).
    func updateMapping(for gesture: AirMouseGesture, to action: MacroAction) {
        gestureMappings[gesture] = action
    }

    /// Reset mappings back to defaults.
    func resetToDefaultMappings() {
        gestureMappings = Self.defaultMappings()
    }

    // MARK: - Default Mappings

    /// These are the predefined defaults (e.g. upSwipe → Up Arrow, tap → left click, etc.).
    static func defaultMappings() -> [AirMouseGesture: MacroAction] {
        return [
            .upSwipe:       .keyPress(keyCode: 0x7E), // Up Arrow
            .downSwipe:     .keyPress(keyCode: 0x7D), // Down Arrow
            .leftSwipe:     .keyPress(keyCode: 0x7B), // Left Arrow
            .rightSwipe:    .keyPress(keyCode: 0x7C), // Right Arrow

            .tap:           .leftClick,
            .clench:        .rightClick,

            .clockSwipe:    .none,
            .counterSwipe:  .none
        ]
    }

    // MARK: - Persistence

    private func loadMappingsIfNeeded() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: mappingsDefaultsKey) {
            do {
                let decoded = try JSONDecoder().decode([String: MacroAction].self, from: data)
                var result: [AirMouseGesture: MacroAction] = [:]
                for (key, action) in decoded {
                    if let gesture = AirMouseGesture(rawValue: key) {
                        result[gesture] = action
                    }
                }
                self.gestureMappings = result
                return
            } catch {
                print("[MacConnection] Failed to decode saved mappings, using defaults. Error: \(error)")
            }
        }

        // If we get here, no valid stored mappings; use defaults
        self.gestureMappings = Self.defaultMappings()
    }

    private func saveMappings() {
        var encodable: [String: MacroAction] = [:]
        for (gesture, action) in gestureMappings {
            encodable[gesture.rawValue] = action
        }

        do {
            let data = try JSONEncoder().encode(encodable)
            UserDefaults.standard.set(data, forKey: mappingsDefaultsKey)
        } catch {
            print("[MacConnection] Failed to save mappings: \(error)")
        }
    }

    // MARK: - Gesture Handling

    private func handleGesture(_ gesture: AirMouseGesture) {
        lastGesture = gesture

        guard let action = gestureMappings[gesture] else {
            print("[MacConnection] No mapping found for gesture \(gesture.rawValue)")
            return
        }

        perform(action: action)
    }

    private func perform(action: MacroAction) {
        switch action {
        case .none:
            // Do nothing
            return

        case .keyPress(let keyCode):
            sendKeyPress(keyCode: keyCode)

        case .leftClick:
            sendMouseClick(button: .left)

        case .rightClick:
            sendMouseClick(button: .right)
        }
    }

    // MARK: - Low-Level Input Events

    /// Sends a simple key press (down + up) for a given key code.
    private func sendKeyPress(keyCode: UInt16) {
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true)
        let keyUp   = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        print("[MacConnection] Sent key press for keyCode \(keyCode)")
    }

    /// Sends a mouse click at the current cursor position.
    private func sendMouseClick(button: CGMouseButton) {
        guard let currentEvent = CGEvent(source: nil) else {
            print("[MacConnection] Could not get current mouse position.")
            return
        }

        let location = currentEvent.location

        let downType: CGEventType
        let upType: CGEventType

        switch button {
        case .left:
            downType = .leftMouseDown
            upType   = .leftMouseUp
        case .right:
            downType = .rightMouseDown
            upType   = .rightMouseUp
        default:
            downType = .otherMouseDown
            upType   = .otherMouseUp
        }

        let mouseDown = CGEvent(mouseEventSource: nil,
                                mouseType: downType,
                                mouseCursorPosition: location,
                                mouseButton: button)

        let mouseUp = CGEvent(mouseEventSource: nil,
                              mouseType: upType,
                              mouseCursorPosition: location,
                              mouseButton: button)

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)

        print("[MacConnection] Sent mouse click: \(button == .left ? "left" : "right")")
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
            print("[MacConnection] Received gesture: \(gesture.rawValue)")
            self.handleGesture(gesture)
        }
    }

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
