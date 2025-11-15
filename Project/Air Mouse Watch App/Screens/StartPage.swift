//
//  StartPage.swift
//  Air Mouse
//
//  Created by Krishiv Panchal on 2025-11-15.
//

import SwiftUI

struct StartPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack {
                Text("Gestures")
                    .font(.title2)
                    .foregroundColor(Color("Text"))
                
                Text("Connected to Mac")
                    .font(.footnote)
                    .foregroundColor(Color("Green"))
                
                Spacer().frame(height: 20) // Spacing before buttons
            }
            
            HStack {
                GestureButton(title: "Click Me", action: { print("Success!") })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}


#Preview {
    StartPage()
}

