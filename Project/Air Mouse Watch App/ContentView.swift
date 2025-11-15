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
                .font(.system(size: 45, weight: .bold))
                .foregroundColor(Color("Text"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.top, 10)
            
            Spacer()
        }
        
        VStack {
            CustomButton(
                title: "Start",
                action: { print("Start tapped") },
                buttonColor: Color("Blue")
            )
            
            CustomButton(
                title: "Configure",
                action: { print("Configure tapped") },
                buttonColor: Color("Green")
            )
            
            CustomButton(
                title: "Settings",
                action: { print("Settings tapped") },
                buttonColor: Color("Purple")
            )
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
