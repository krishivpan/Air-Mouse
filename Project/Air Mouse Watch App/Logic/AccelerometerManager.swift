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
    @Published var detectedSwipeRight = false
    
    private let leftSwipeThreshold = -0.8  // tweak this until it feels right
    private let rightSwipeThreshold = 1.0  //
    
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
        if xValue < leftSwipeThreshold {
            detectedSwipeLeft = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.detectedSwipeLeft = false
            }
        }
    }
    
    private func detectSwipeRight(from xValue: Double) {
        if xValue > rightSwipeThreshold {
            detectedSwipeRight = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.detectedSwipeRight = false
        }
    }
}
