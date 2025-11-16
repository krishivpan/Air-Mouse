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

    private var baselineX: Double = 0
    private var baselineY: Double = 0

    // MARK: - Thresholds
    private let threshold: Double = 0.7
    private let debounceInterval: TimeInterval = 0.35
    private var lastSwipeTime = Date.distantPast

    // MARK: - Start Accelerometer
    func start() {
        guard motion.isAccelerometerAvailable else { return }

        motion.accelerometerUpdateInterval = 0.02
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self,
                  let raw = data?.acceleration else { return }

            let correctedX = raw.x - self.baselineX
            let correctedY = raw.y - self.baselineY
            let now = Date()

            guard now.timeIntervalSince(self.lastSwipeTime) > self.debounceInterval else { return }

            // LEFT
            if self.detectLeft && correctedX < -self.threshold {
                self.trigger(.left)
            }
            // RIGHT
            if self.detectRight && correctedX > self.threshold {
                self.trigger(.right)
            }
            // UP
            if self.detectUp && correctedY > self.threshold {
                self.trigger(.up)
            }
            // DOWN
            if self.detectDown && correctedY < -self.threshold {
                self.trigger(.down)
            }
        }
    }

    func stop() {
        motion.stopAccelerometerUpdates()
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

    // MARK: - Calibration (3-Second Countdown)
    func recalibrate() {
        isCalibrating = true
        calibrationCountdown = 3

        // Countdown animation
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.calibrationCountdown -= 1

            if self.calibrationCountdown <= 0 {
                timer.invalidate()
                self.finishCalibration()
            }
        }
    }

    private func finishCalibration() {
        guard let accel = motion.accelerometerData?.acceleration else {
            isCalibrating = false
            return
        }

        baselineX = accel.x
        baselineY = accel.y

        isCalibrating = false
    }
}
