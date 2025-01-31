//
//  WelcomeView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  First-launch screen with login/signup or guest mode.
//  Modern gradient background depending on light/dark mode.
//
//  Displays:
//    Top-left: "Welcome"
//    Centered: "LIVE Match - Matchmaker", version number, app description
//    Buttons: "Log In / Sign Up" and "Continue as Guest"
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Welcome")
                            .font(.title3)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text("LIVE Match - Matchmaker")
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                        
                        Text("Version \(appVersion())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Set, create and find a LIVE Match or game simpler and based on your parameters")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    NavigationLink("Log In / Sign Up", destination: SignInView())
                        .font(.headline)
                        .padding(.vertical, 8)
                    
                    Button("Continue as a Guest") {
                        AuthManager.shared.signInAsGuest()
                    }
                    .font(.headline)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    
    private func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
