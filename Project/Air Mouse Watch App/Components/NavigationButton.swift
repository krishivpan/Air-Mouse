//
//  CustomButton.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct NavigationButton: View {
    let title: String
    let buttonColor: Color
    let icon: Image? // Optional icon
    @State private var isPressed = false

    // Add this initializer with a default value for icon
    init(title: String, buttonColor: Color, icon: Image? = nil) {
        self.title = title
        self.buttonColor = buttonColor
        self.icon = icon
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            if let icon = icon {
                Spacer()
                icon
                    .foregroundColor(Color("Text"))
            }
        }
        .frame(width: 180, height: 50)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(buttonColor.opacity(isPressed ? 0.8 : 0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(buttonColor, lineWidth: 1)
        )
        .foregroundColor(Color("Text"))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(), value: isPressed)
    }
}
