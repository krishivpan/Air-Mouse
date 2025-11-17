import SwiftUI
import WatchKit
import Combine
import HealthKit

final class WorkoutSessionController: NSObject, ObservableObject {
    @Published var isRunning: Bool = false
    
    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    func startSession() {
        // Request authorization
        let typesToShare: Set = [HKQuantityType.workoutType()]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                self.beginWorkout()
            }
        }
    }
    
    private func beginWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in
                DispatchQueue.main.async {
                    self.isRunning = success
                }
            }
        } catch {
            print("Failed to start workout: \(error)")
        }
    }
    
    func endSession() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { success, error in
            self.builder?.finishWorkout { workout, error in
                DispatchQueue.main.async {
                    self.isRunning = false
                }
            }
        }
    }
}

struct breathingCircle: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.8),
                            Color.blue.opacity(0.9),
                            Color.purple.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .scaleEffect(scale)
                .opacity(opacity)
            
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 6, height: 6)
        }
        .frame(width: 70, height: 70)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.15
                opacity = 0.95
            }
        }
    }
}

struct StartPage: View {
    @EnvironmentObject private var watchSession: WatchSessionManager
    @ObservedObject private var accel = AccelerometerManager.shared
    @StateObject private var workoutController = WorkoutSessionController()
    
    @State private var currentGesture: AirMouseGesture?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.07, green: 0.07, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 8) {
                
                Spacer()
                    .frame(height: 20)

                // MARK: Header Card
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gestures")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 8)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(watchSession.isReachable ? Color.green : Color.red)
                            .frame(width: 8, height: 8)

                        Text(watchSession.isReachable ? "Connected to iPhone" : "Not Connected")
                            .font(.system(size: 11))
                            .foregroundColor(watchSession.isReachable ? .green : .red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)

                // MARK: Gesture Detection Card
                ZStack {
                    if accel.isCalibrating {
                        calibratingView
                    } else if accel.calibrationDone {
                        calibrationDoneView
                    } else if currentGesture == nil {
                        breathingCircle()
                            .transition(.scale.combined(with: .opacity))
                            .contentShape(Circle())
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded { _ in
                                        handleTap()
                                    }
                            )
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        triggerCalibration()
                                    }
                            )
                    } else {
                        gestureIcon(for: currentGesture!)
                            .transition(.scale(scale: 1.2).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 90)
                .padding()
                .onChange(of: accel.detectedSwipeLeft) { _, newValue in
                    if newValue {
                        WKInterfaceDevice.current().play(.success)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            currentGesture = .leftSwipe
                        }
                        watchSession.sendGesture(.leftSwipe)
                        resetGesture()
                    }
                }
                .onChange(of: accel.detectedSwipeRight) { _, newValue in
                    if newValue {
                        WKInterfaceDevice.current().play(.success)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            currentGesture = .rightSwipe
                        }
                        watchSession.sendGesture(.rightSwipe)
                        resetGesture()
                    }
                }
                .onChange(of: accel.detectedSwipeUp) { _, newValue in
                    if newValue {
                        WKInterfaceDevice.current().play(.success)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            currentGesture = .upSwipe
                        }
                        watchSession.sendGesture(.upSwipe)
                        resetGesture()
                    }
                }
                .onChange(of: accel.detectedSwipeDown) { _, newValue in
                    if newValue {
                        WKInterfaceDevice.current().play(.success)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            currentGesture = .downSwipe
                        }
                        watchSession.sendGesture(.downSwipe)
                        resetGesture()
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            accel.start()
            workoutController.startSession()
        }
        .onDisappear {
            accel.stop()
            workoutController.endSession()
        }
    }
    
    private func gestureIcon(for gesture: AirMouseGesture) -> some View {
        let iconData = getIconData(for: gesture)
        
        return ZStack {
            Circle()
                .fill(iconData.color.opacity(0.3))
                .frame(width: 80, height: 80)
                .blur(radius: 10)
            
            Image(systemName: iconData.name)
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [iconData.color, iconData.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private func getIconData(for gesture: AirMouseGesture) -> (name: String, color: Color) {
        switch gesture {
        case .tap:
            return ("hand.tap.fill", .cyan)
        case .leftSwipe:
            return ("arrow.left.circle.fill", .green)
        case .rightSwipe:
            return ("arrow.right.circle.fill", .blue)
        case .upSwipe:
            return ("arrow.up.circle.fill", .orange)
        case .downSwipe:
            return ("arrow.down.circle.fill", .red)
        default:
            return ("circle.fill", .white)
        }
    }
    
    private func resetGesture() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                currentGesture = nil
            }
        }
    }
    
    // MARK: - Calibration Views
    private var calibratingView: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(accel.calibrationCountdown == 3 ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: accel.calibrationCountdown)
                
                Text("\(accel.calibrationCountdown)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Hold still...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var calibrationDoneView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 55))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(accel.calibrationDone ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: accel.calibrationDone)
            
            Text("Calibrated!")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.green)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private func triggerCalibration() {
        WKInterfaceDevice.current().play(.start)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentGesture = nil
        }
        accel.recalibrate()
    }
    
    private func handleTap() {
        guard accel.detectTap else { return }
        
        WKInterfaceDevice.current().play(.click)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            currentGesture = .tap
        }
        watchSession.sendGesture(.tap)
        resetGesture()
    }
}

#Preview {
    StartPage()
        .environmentObject(WatchSessionManager.shared)
}
