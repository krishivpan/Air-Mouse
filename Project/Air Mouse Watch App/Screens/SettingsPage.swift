import SwiftUI

struct SettingsPage: View {
    @ObservedObject var accel = AccelerometerManager.shared

    var body: some View {
        ZStack {
            // Dark, techy background
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.07, green: 0.07, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Gesture Detection Card
                    gestureDetectionCard
                    
                    // MARK: - Calibration Card
                    calibrationCard
                    
                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension SettingsPage {
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Settings")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.purple, Color.purple.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Configure gestures")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }
    
    var gestureDetectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gesture Detection")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                toggleRow(label: "Tap", isOn: $accel.detectTap)
                toggleRow(label: "Left Swipe", isOn: $accel.detectLeft)
                toggleRow(label: "Right Swipe", isOn: $accel.detectRight)
                toggleRow(label: "Up Swipe", isOn: $accel.detectUp)
                toggleRow(label: "Down Swipe", isOn: $accel.detectDown)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.18),
                            Color(red: 0.08, green: 0.08, blue: 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
        )
    }
    
    func toggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.blue)
                .scaleEffect(1.1)
        }
        .padding(.vertical, 4)
    }
    
    var calibrationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calibration")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            if accel.isCalibrating {
                calibratingView
            } else if accel.calibrationDone {
                calibrationDoneView
            } else {
                calibrationButton
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.18),
                            Color(red: 0.08, green: 0.08, blue: 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
        )
    }
    
    var calibratingView: some View {
        VStack(spacing: 8) {
            Text("Hold still...")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            
            Text("\(accel.calibrationCountdown)")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    var calibrationDoneView: some View {
        HStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.green)
                .scaleEffect(accel.calibrationDone ? 1.1 : 0.5)
                .opacity(accel.calibrationDone ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: accel.calibrationDone)
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    var calibrationButton: some View {
        Button(action: {
            accel.recalibrate()
        }) {
            HStack {
                Spacer()
                Text("Recalibrate")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsPage()
    }
}
