// MARK: File 9: MatchmakingView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct MatchmakingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("Matchmaking Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("For gamers to squad up or collaborate in matches against each other, in games like Call of Duty, Fortnite, and more.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Text("Coming Soon!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                    .padding(.top, 16)
            }
        }
    }
}
