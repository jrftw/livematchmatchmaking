// MARK: - WelcomeView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Fix: Convert inline prints in the body to side effects using `let _ = print(...)`.
// Return a single View (NavigationView) expression.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var selectedScreen: MainScreen
    
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
        let _ = print("[WelcomeView] init called.")
    }
    
    public var body: some View {
        // Convert the top-level print into a side effect so SwiftUI sees one expression.
        let _ = print("[WelcomeView] body invoked.")
        
        return NavigationView {
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
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
                    
                    VStack(spacing: 12) {
                        NavigationLink("Log In / Sign Up") {
                            SignInView(selectedScreen: $selectedScreen)
                        }
                        .font(.headline)
                        .padding(.vertical, 8)
                        
                        Button("Continue as a Guest") {
                            AuthManager.shared.signInAsGuest()
                            // If you want to show the menu or profile automatically:
                            // selectedScreen = .menu
                        }
                        .font(.headline)
                    }
                    
                    Spacer()
                }
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
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version
    }
}
