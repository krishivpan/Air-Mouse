//
//  GestureMacroManager.swift
//  Air Mouse
//
//  Created by Rehan Jetha on 2025-11-16.
//

import Foundation
import Combine
import AppKit
import CoreGraphics

/// The simple actions a gesture can trigger.
enum MacroTarget: String, CaseIterable, Identifiable, Codable {
    case none
    case arrowUp
    case arrowDown
    case arrowLeft
    case arrowRight
    case leftClick
    case rightClick

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:        return "None"
        case .arrowUp:     return "Up Arrow"
        case .arrowDown:   return "Down Arrow"
        case .arrowLeft:   return "Left Arrow"
        case .arrowRight:  return "Right Arrow"
        case .leftClick:   return "Left Click"
        case .rightClick:  return "Right Click"
        }
    }
}

/// Listens for incoming gestures and fires the selected macro for each gesture.
/// Also persists the mapping in UserDefaults.
final class GestureMacroManager: ObservableObject {

    static let shared = GestureMacroManager()

    /// Current mapping: gesture → macro action
    @Published var bindings: [AirMouseGesture: MacroTarget]

    private let storageKey = "GestureMacroBindings"
    private var cancellables = Set<AnyCancellable>()

    private init(session: MacSessionManager = .shared) {
        self.bindings = Self.loadBindings() ?? Self.defaultBindings()

        // Whenever a gesture arrives from the phone, perform the bound action.
        session.$lastGesture
            .compactMap { $0 }
            .sink { [weak self] gesture in
                self?.handle(gesture)
            }
            .store(in: &cancellables)

        // Persist whenever bindings change.
        $bindings
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveBindings()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func setBinding(for gesture: AirMouseGesture, to target: MacroTarget) {
        bindings[gesture] = target
    }

    func resetToDefaults() {
        bindings = Self.defaultBindings()
    }

    // MARK: - Persistence

    private static func defaultBindings() -> [AirMouseGesture: MacroTarget] {
        [
            .upSwipe:        .arrowUp,
            .downSwipe:      .arrowDown,
            .leftSwipe:      .arrowLeft,
            .rightSwipe:     .arrowRight,
            .tap:            .leftClick,
            .clench:         .none,
            .clockSwipe:     .none,
            .counterSwipe:   .none
        ]
    }

    private static func loadBindings() -> [AirMouseGesture: MacroTarget]? {
        guard
            let data = UserDefaults.standard.data(forKey: "GestureMacroBindings"),
            let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            return nil
        }

        var result: [AirMouseGesture: MacroTarget] = [:]
        for (gestureRaw, targetRaw) in decoded {
            guard
                let gesture = AirMouseGesture(rawValue: gestureRaw),
                let target = MacroTarget(rawValue: targetRaw)
            else { continue }
            result[gesture] = target
        }
        return result
    }

    private func saveBindings() {
        var encoded: [String: String] = [:]
        for (gesture, target) in bindings {
            encoded[gesture.rawValue] = target.rawValue
        }

        if let data = try? JSONEncoder().encode(encoded) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Gesture handling

    private func handle(_ gesture: AirMouseGesture) {
        guard let target = bindings[gesture], target != .none else { return }
        perform(target)
    }

    private func perform(_ target: MacroTarget) {
        switch target {
        case .none:
            break

        case .arrowUp:
            sendKey(keyCode: 0x7E)
        case .arrowDown:
            sendKey(keyCode: 0x7D)
        case .arrowLeft:
            sendKey(keyCode: 0x7B)
        case .arrowRight:
            sendKey(keyCode: 0x7C)

        case .leftClick:
            sendMouseClick(button: .left)
        case .rightClick:
            sendMouseClick(button: .right)
        }
    }

    // MARK: - Low-level event helpers

    private func sendKey(keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp   = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func sendMouseClick(button: CGMouseButton) {
        // Get the CURRENT mouse location without creating any events that might move it
        let currentLocation = CGEvent(source: nil)?.location ?? NSEvent.mouseLocation
        
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let downType: CGEventType = (button == .left) ? .leftMouseDown : .rightMouseDown
        let upType: CGEventType   = (button == .left) ? .leftMouseUp   : .rightMouseUp

        // Create mouse events at the EXACT current location - don't move the cursor
        let down = CGEvent(
            mouseEventSource: source,
            mouseType: downType,
            mouseCursorPosition: currentLocation,
            mouseButton: button
        )
        let up = CGEvent(
            mouseEventSource: source,
            mouseType: upType,
            mouseCursorPosition: currentLocation,
            mouseButton: button
        )

        // Post the events
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}
