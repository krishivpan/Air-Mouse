import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var accel: AccelerometerManager

    var body: some View {
        Form {
            Section("Gesture Detection") {
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
