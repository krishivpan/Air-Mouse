//
//  CustomButton.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    let buttonColor: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 180, height: 50)
                .background (
                    RoundedRectangle(cornerRadius: 18)
                        .fill(buttonColor.opacity(isPressed ? 0.8 : 0.4))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(buttonColor, lineWidth: 1)
                )
                .foregroundColor(Color("Text"))
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
