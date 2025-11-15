//
//  ContentView.swift
//  Air Mouse Watch App
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI



struct ContentView: View {
    
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            // Create the Welcome User title
            
            Text("Welcome User!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("Text"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.top, 10)
            
            Spacer()
        }
        
        VStack {
            Button(action: {
                print("Success")
            }) {
                Text("Start")
                    .fontWeight(.bold)
                    .frame(width: 120, height: 50)
                    .background (
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Blue").opacity(isPressed ? 0.8 : 0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Blue"), lineWidth: 2)
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
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
