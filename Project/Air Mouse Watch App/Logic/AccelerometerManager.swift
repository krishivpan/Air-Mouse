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
    
    private var baselineY: Double = 0
    private var baselineZ: Double = 0  // Changed from baselineX to baselineZ
    
    // MARK: - Thresholds
    private let threshold: Double = 1.2
    private let debounceInterval: TimeInterval = 0.35
    private var lastSwipeTime = Date.distantPast
    
    // MARK: - Start Device Motion (filters out gravity)
    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        
        motion.deviceMotionUpdateInterval = 0.02
        
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let motion = data else { return }
            
            let userAccel = motion.userAcceleration
            
            // Apply baseline calibration
            // Y-axis: up/down (toward top of screen)
            // Z-axis: left/right (when hand is rotated 90° counterclockwise)
            let dy = userAccel.y - self.baselineY
            let dz = userAccel.z - self.baselineZ
            
            let now = Date()
            guard now.timeIntervalSince(self.lastSwipeTime) > self.debounceInterval else { return }
            
            let absY = abs(dy)
            let absZ = abs(dz)
            
            // Determine primary direction (Y or Z) - only trigger the dominant axis
            if absZ > absY {
                // Horizontal movement dominant (Z-axis for left/right)
                // When hand moves forward (away from body): Z increases -> RIGHT
                // When hand moves backward (toward body): Z decreases -> LEFT
                if self.detectRight && dz > self.threshold {
                    self.trigger(.right)
                } else if self.detectLeft && dz < -self.threshold {
                    self.trigger(.left)
                }
            } else {
                // Vertical movement dominant (Y-axis for up/down)
                if self.detectUp && dy > self.threshold {
                    self.trigger(.up)
                } else if self.detectDown && dy < -self.threshold {
                    self.trigger(.down)
                }
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
        var capturedUserAccel: CMAcceleration?
        
        if motion.isDeviceMotionAvailable {
            motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let motion = data else { return }
                capturedUserAccel = motion.userAcceleration
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, let userAccel = capturedUserAccel else {
                    self?.isCalibrating = false
                    return
                }
                
                // Set baseline to current userAcceleration
                self.baselineY = userAccel.y
                self.baselineZ = userAccel.z  // Changed from baselineX to baselineZ
                
                self.isCalibrating = false
                self.calibrationDone = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.calibrationDone = false
                }
            }
        } else {
            isCalibrating = false
        }
    }
}
