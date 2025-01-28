// MARK: File 5: ContentView.swift
// MARK: Entry point after SplashView. Checks AuthManager.user and .isGuest.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            // If no Firebase user & not guest => show WelcomeView
            if authManager.user == nil && !authManager.isGuest {
                WelcomeView()
            } else {
                MainMenuView()
            }
        }
    }
}
