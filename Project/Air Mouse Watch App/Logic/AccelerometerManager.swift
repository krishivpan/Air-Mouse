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
    @Published var x: Double = 0
    @Published var y: Double = 0
    @Published var z: Double = 0
    
    @Published var detectedSwipeLeft = false
    
    private let swipeThreshold = -1.2  // Tweak this until it feels right
    
    
    func start() {
        motion.accelerometerUpdateInterval = 0.02
        
        motion.startAccelerometerUpdates(to: .main) {
            
            data, error in guard let accel = data?.acceleration else { return }
            
            self.x = accel.x
            self.y = accel.y
            self.z = accel.z
            
            self.detectSwipeLeft(from: accel.x)
        }
    }
    
    func stop() {
        motion.stopAccelerometerUpdates()
    }
    
    private func detectSwipeLeft(from xValue: Double) {
        if xValue < swipeThreshold {
            detectedSwipeLeft = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.detectedSwipeLeft = false
            }
        }
    }
}
