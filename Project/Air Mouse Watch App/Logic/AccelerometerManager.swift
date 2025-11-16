//
//  AccelerometerManager.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import CoreMotion
import Foundation
import Combine

class AccelerometerManager: ObservableObject {
    private let motion = CMMotionManager()
    
    // MARK: - Published properties for SwiftUI
    @Published var detectedSwipeLeft = false
    @Published var detectedSwipeRight = false
    @Published var detectedSwipeUp = false
    @Published var detectedSwipeDown = false
    
    // MARK: - Thresholds (tweak based on wrist motion)
    private let leftSwipeThreshold: Double = -0.8
    private let rightSwipeThreshold: Double = 0.8
    private let upSwipeThreshold: Double = 0.8
    private let downSwipeThreshold: Double = -0.8
    
    // MARK: - Debounce to prevent multiple triggers
    private var lastSwipeTime: Date = Date.distantPast
    private let debounceInterval: TimeInterval = 0.3
    
    // MARK: - Start accelerometer
    func start() {
        motion.accelerometerUpdateInterval = 0.02
        
        guard motion.isAccelerometerAvailable else { return }
        
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let accel = data?.acceleration else { return }
            
            let now = Date()
            guard now.timeIntervalSince(self.lastSwipeTime) > self.debounceInterval else { return }
            
            // Detect swipes
            if accel.x < self.leftSwipeThreshold {
                self.triggerSwipe(.left)
            } else if accel.x > self.rightSwipeThreshold {
                self.triggerSwipe(.right)
            } else if accel.y > self.upSwipeThreshold {
                self.triggerSwipe(.up)
            } else if accel.y < self.downSwipeThreshold {
                self.triggerSwipe(.down)
            }
        }
    }
    
    // MARK: - Stop accelerometer
    func stop() {
        motion.stopAccelerometerUpdates()
    }
    
    // MARK: - Swipe detection
    private enum SwipeDirection {
        case left, right, up, down
    }
    
    private func triggerSwipe(_ direction: SwipeDirection) {
        lastSwipeTime = Date()
        
        switch direction {
        case .left:
            detectedSwipeLeft = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.detectedSwipeLeft = false
            }
        case .right:
            detectedSwipeRight = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.detectedSwipeRight = false
            }
        case .up:
            detectedSwipeUp = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.detectedSwipeUp = false
            }
        case .down:
            detectedSwipeDown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.detectedSwipeDown = false
            }
        }
    }
}
