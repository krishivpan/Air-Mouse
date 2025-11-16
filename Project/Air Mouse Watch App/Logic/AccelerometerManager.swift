import CoreMotion
import Foundation
import Combine

class AccelerometerManager: ObservableObject {
    private let motion = CMMotionManager()
    
    // MARK: - Published Gesture Toggles
    @Published var detectLeft = true
    @Published var detectRight = true
    @Published var detectUp = true
    @Published var detectDown = true
    
    // MARK: - Published Swipe Detection
    @Published var detectedSwipeLeft = false
    @Published var detectedSwipeRight = false
    @Published var detectedSwipeUp = false
    @Published var detectedSwipeDown = false
    
    // MARK: - Calibration Properties
    @Published var isCalibrating = false
    @Published var calibrationCountdown = 0
    @Published var calibrationDone = false
    
    private var baselineX: Double = 0
    private var baselineY: Double = 0
    
    // MARK: - Thresholds (increased for user acceleration)
    private let threshold: Double = 1.5  // Higher threshold for actual movement
    private let debounceInterval: TimeInterval = 0.35
    private var lastSwipeTime = Date.distantPast
    
    // MARK: - Start Device Motion (filters out gravity)
    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        
        motion.deviceMotionUpdateInterval = 0.02
        
        // Use deviceMotion instead of accelerometer - this filters out gravity!
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let motion = data else { return }
            
            // userAcceleration excludes gravity - only actual movement
            let userAccel = motion.userAcceleration
            
            // Apply baseline calibration
            let dx = userAccel.x - self.baselineX
            let dy = userAccel.y - self.baselineY
            
            let now = Date()
            guard now.timeIntervalSince(self.lastSwipeTime) > self.debounceInterval else { return }
            
            // LEFT (negative X)
            if self.detectLeft && dx < -self.threshold {
                self.trigger(.left)
            }
            // RIGHT (positive X)
            if self.detectRight && dx > self.threshold {
                self.trigger(.right)
            }
            // UP (positive Y)
            if self.detectUp && dy > self.threshold {
                self.trigger(.up)
            }
            // DOWN (negative Y)
            if self.detectDown && dy < -self.threshold {
                self.trigger(.down)
            }
        }
    }
    
    func stop() {
        motion.stopDeviceMotionUpdates()
    }
    
    // MARK: - Swipe Trigger
    private enum Dir { case left, right, up, down }
    
    private func trigger(_ dir: Dir) {
        lastSwipeTime = Date()
        
        switch dir {
        case .left:
            detectedSwipeLeft = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.detectedSwipeLeft = false }
        case .right:
            detectedSwipeRight = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.detectedSwipeRight = false }
        case .up:
            detectedSwipeUp = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.detectedSwipeUp = false }
        case .down:
            detectedSwipeDown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.detectedSwipeDown = false }
        }
    }
    
    // MARK: - Calibration (3-second countdown)
    func recalibrate() {
        isCalibrating = true
        calibrationCountdown = 3
        calibrationDone = false
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.calibrationCountdown -= 1
            
            if self.calibrationCountdown <= 0 {
                timer.invalidate()
                self.finishCalibration()
            }
        }
    }
    
    private func finishCalibration() {
        // Temporarily store the current motion data
        var capturedUserAccel: CMAcceleration?
        
        // Start a quick update just to get the current state
        if motion.isDeviceMotionAvailable {
            motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let motion = data else { return }
                capturedUserAccel = motion.userAcceleration
            }
            
            // Wait a moment to capture the data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, let userAccel = capturedUserAccel else {
                    self?.isCalibrating = false
                    return
                }
                
                // Set baseline to current userAcceleration (should be ~0 when still)
                self.baselineX = userAccel.x
                self.baselineY = userAccel.y
                
                self.isCalibrating = false
                self.calibrationDone = true
                
                // Auto-hide checkmark after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.calibrationDone = false
                }
            }
        } else {
            isCalibrating = false
        }
    }
}
