//
//  ContentView.swift
//  Air Mouse Watch App
//
//  Created by Rehan Jetha on 2025-11-15.
//

import SwiftUI



struct ContentView: View {
    @State private var test = "Hello Watch"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("sdaf!")
            
            Button(test) {
                print("Hello")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("Accent"))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
