//
//  ContentView.swift
//  Air Mouse Mac
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var macSession: MacSessionManager

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

            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Air Mouse – Mac")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Listening for gestures from your iPhone.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Connection status
                HStack {
                    Text("iPhone Connection")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 6) {
                        Circle()
                            .fill(macSession.isPhoneConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(macSession.isPhoneConnected ? "Connected" : "Not Connected")
                            .foregroundColor(macSession.isPhoneConnected ? .green : .red)
                            .font(.subheadline)
                    }
                }

                // Gesture display
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last Gesture")
                        .font(.headline)
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.16, green: 0.16, blue: 0.24),
                                    Color(red: 0.10, green: 0.10, blue: 0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            HStack {
                                Text(prettyGestureName(macSession.lastGesture))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        )
                        .frame(height: 70)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func prettyGestureName(_ gesture: AirMouseGesture?) -> String {
        guard let gesture = gesture else { return "Waiting for Gesture..." }

        switch gesture {
        case .leftSwipe:      return "Left Swipe"
        case .rightSwipe:     return "Right Swipe"
        case .upSwipe:        return "Up Swipe"
        case .downSwipe:      return "Down Swipe"
        case .clockSwipe:     return "Clockwise Swipe"
        case .counterSwipe:   return "Counter-Clockwise Swipe"
        case .tap:            return "Tap"
        case .clench:         return "Clench"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(MacSessionManager())
}
