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
    private var baselineZ: Double = 0
    
    // MARK: - Velocity Tracking (integrated from acceleration)
    private var velocityY: Double = 0
    private var velocityZ: Double = 0
    private var lastUpdateTime: Date = Date()
    
    // MARK: - Thresholds
    private let accelerationThreshold: Double = 1.2  // Initial acceleration to start tracking
    private let velocityThreshold: Double = 0.45     // ~27cm swipe over ~0.3s
    private let debounceInterval: TimeInterval = 0.35
    private var lastSwipeTime = Date.distantPast
    
    // Velocity decay - gradually reduce velocity when no significant acceleration
    private let velocityDecay: Double = 0.92
    
    // MARK: - Start Device Motion (filters out gravity)
    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        
        motion.deviceMotionUpdateInterval = 0.02
        lastUpdateTime = Date()
        
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let motion = data else { return }
            
            let now = Date()
            let dt = now.timeIntervalSince(self.lastUpdateTime)
            self.lastUpdateTime = now
            
            let userAccel = motion.userAcceleration
            
            // Apply baseline calibration
            let dy = userAccel.y - self.baselineY
            let dz = userAccel.z - self.baselineZ
            
            // Integrate acceleration to get velocity (v = v0 + a*dt)
            // Only integrate if acceleration is significant, otherwise decay
            if abs(dy) > 0.3 {
                self.velocityY += dy * dt
            } else {
                self.velocityY *= self.velocityDecay
            }
            
            if abs(dz) > 0.3 {
                self.velocityZ += dz * dt
            } else {
                self.velocityZ *= self.velocityDecay
            }
            
            // Debounce check
            guard now.timeIntervalSince(self.lastSwipeTime) > self.debounceInterval else { return }
            
            let absVelY = abs(self.velocityY)
            let absVelZ = abs(self.velocityZ)
            
            // Check if acceleration is above initial threshold AND velocity is sufficient
            let absAccelY = abs(dy)
            let absAccelZ = abs(dz)
            
            // Determine primary direction - only trigger if both acceleration and velocity thresholds met
            if absVelZ > absVelY && absVelZ > self.velocityThreshold {
                if self.detectRight && dz > self.accelerationThreshold && self.velocityZ > self.velocityThreshold {
                    self.trigger(.right)
                    self.velocityZ = 0  // Reset velocity after detection
                } else if self.detectLeft && dz < -self.accelerationThreshold && self.velocityZ < -self.velocityThreshold {
                    self.trigger(.left)
                    self.velocityZ = 0
                }
            } else if absVelY > absVelZ && absVelY > self.velocityThreshold {
                if self.detectUp && dy > self.accelerationThreshold && self.velocityY > self.velocityThreshold {
                    self.trigger(.up)
                    self.velocityY = 0
                } else if self.detectDown && dy < -self.accelerationThreshold && self.velocityY < -self.velocityThreshold {
                    self.trigger(.down)
                    self.velocityY = 0
                }
            }
        }
    }
    
    func stop() {
        motion.stopDeviceMotionUpdates()
        velocityY = 0
        velocityZ = 0
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
        
        // Reset velocities during calibration
        velocityY = 0
        velocityZ = 0
        
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
                self.baselineZ = userAccel.z
                
                // Reset velocities
                self.velocityY = 0
                self.velocityZ = 0
                self.lastUpdateTime = Date()
                
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
