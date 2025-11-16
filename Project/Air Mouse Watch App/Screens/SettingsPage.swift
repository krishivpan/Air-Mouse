import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var accel: AccelerometerManager

    var body: some View {
        Form {
            Section(header: Text("Gesture Detection")) {
                Toggle("Left Swipe", isOn: $accel.detectLeft)
                Toggle("Right Swipe", isOn: $accel.detectRight)
                Toggle("Up Swipe", isOn: $accel.detectUp)
                Toggle("Down Swipe", isOn: $accel.detectDown)
            }
            
            
            Section("Calibration") {
                if accel.isCalibrating {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Text("Hold still...")
                                .font(.headline)
                            
                            Text("\(accel.calibrationCountdown)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                } else if accel.calibrationDone {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                            .scaleEffect(accel.calibrationDone ? 1.2 : 0.5)
                            .opacity(accel.calibrationDone ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: accel.calibrationDone)
                        Spacer()
                    }
                } else {
                    Button("Recalibrate Neutral Position") {
                        accel.recalibrate()
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    SettingsPage()
        .environmentObject(AccelerometerManager())
}
