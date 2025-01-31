//
//  SplashView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays a modern splash screen, then transitions to ContentView after a short delay.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isActive = false
    @State private var progress: Float = 0.0
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image("AppIcon") // Replace with actual asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                    
                    Text("LIVE Match Making - Match Making app")
                        .font(.headline)
                    
                    Text("Created by @ JrFTW")
                        .font(.subheadline)
                    
                    Text("© 2025 Infinitum Imagery LLC & Infinitum_US\nAll rights reserved Infinitum Imagery LLC")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    
                    ProgressView(value: progress, total: 100)
                        .frame(width: 200)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding()
            }
            .onAppear {
                animateProgress()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    isActive = true
                }
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                gradient: Gradient(colors: [.black, .gray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.white, Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func animateProgress() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if progress < 100 {
                progress += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
