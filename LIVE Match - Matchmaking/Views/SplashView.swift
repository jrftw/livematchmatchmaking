// MARK: File 4: SplashView.swift
// MARK: Displays a splash/loading screen, then transitions to ContentView

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Text("LIVE Match - Matchmaking App")
                    .font(.largeTitle)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isActive = true
                }
            }
        }
    }
}
