//
//  WelcomeView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
// MARK: - WelcomeView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// First-launch screen with login/signup or guest mode. Modern gradient background.
// Displays:
//   Top-left: "Welcome"
//   Centered: "LIVE Match - Matchmaker", version number, app description
//   Buttons: "Log In / Sign Up" and "Continue as Guest"

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct WelcomeView: View {
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Init
    init() {
        print("[WelcomeView] init called.")
    }
    
    // MARK: - Body
    var body: some View {
        print("[WelcomeView] body invoked. Building NavigationView and main UI.")
        
        return NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    topWelcomeHeader()
                    
                    Spacer()
                    
                    centerTitleSection()
                    
                    Spacer()
                    
                    loginButtons()
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: LinearGradient {
        print("[WelcomeView] backgroundGradient computed. colorScheme: \(colorScheme).")
        
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
    
    // MARK: - Top Welcome Header
    private func topWelcomeHeader() -> some View {
        print("[WelcomeView] topWelcomeHeader() called. Building 'Welcome' text in HStack.")
        return HStack {
            Text("Welcome")
                .font(.title3)
                .padding(.leading, 16)
            Spacer()
        }
    }
    
    // MARK: - Center Title Section
    private func centerTitleSection() -> some View {
        print("[WelcomeView] centerTitleSection() called. Building title, version, description.")
        return VStack(spacing: 6) {
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
    }
    
    // MARK: - Login Buttons
    private func loginButtons() -> some View {
        print("[WelcomeView] loginButtons() called. Building log in / guest buttons.")
        return VStack(spacing: 12) {
            NavigationLink("Log In / Sign Up", destination: SignInView())
                .font(.headline)
                .padding(.vertical, 8)
            
            Button("Continue as a Guest") {
                print("[WelcomeView] Guest button tapped. Calling AuthManager.shared.signInAsGuest().")
                AuthManager.shared.signInAsGuest()
            }
            .font(.headline)
        }
    }
    
    // MARK: - App Version
    private func appVersion() -> String {
        print("[WelcomeView] appVersion() called.")
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        print("[WelcomeView] appVersion() => \(version)")
        
        return version
    }
}
