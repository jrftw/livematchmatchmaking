// MARK: File 6: WelcomeView.swift
// MARK: First-launch screen with login/signup or guest mode

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to LIVE Match - Matchmaker")
                    .font(.largeTitle)
                NavigationLink("Log In / Sign Up", destination: SignInView())
                Button("Continue as Guest") {
                    AuthManager.shared.signInAsGuest()
                }
            }
            .navigationTitle("First Launch")
        }
    }
}
