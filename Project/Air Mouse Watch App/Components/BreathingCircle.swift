//
//  BreathingCircle.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct BreathingCircle: View {
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.4)) // color of the circle
            .frame(width: 60, height: 60)
            .scaleEffect(animate ? 1.2 : 0.8) // pulse size
            .opacity(animate ? 0.6 : 0.3)     // fade in/out
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}
