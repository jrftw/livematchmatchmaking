// MARK: - ContentView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Remove inline 'print()' statements as direct return expressions. Instead, use 'let _ = print(...)'
// and wrap the main UI in a single Group or single return expression.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ContentView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var selectedScreen: MainScreen = .menu
    
    init() {
        let _ = print("[ContentView] init called. Current user: \(AuthManager.shared.user?.email ?? "nil"), isGuest: \(AuthManager.shared.isGuest)")
    }
    
    var body: some View {
        let _ = print("[ContentView] body invoked. Checking user state: \(authManager.user?.email ?? "nil"), isGuest: \(authManager.isGuest)")
        
        // Wrap the logic in a single View expression (e.g. Group).
        // Use `let _ = print(...)` for debugging.
        
        return Group {
            if authManager.user == nil && !authManager.isGuest {
                let _ = print("[ContentView] Condition => user is nil & isGuest is false => Show WelcomeView")
                
                WelcomeView(selectedScreen: $selectedScreen)
                    .onAppear {
                        let _ = print("[ContentView] onAppear => WelcomeView displayed")
                    }
                
            } else {
                let _ = print("[ContentView] Condition => user != nil OR isGuest => Show RootContainerView")
                
                RootContainerView(selectedScreen: $selectedScreen)
                    .onAppear {
                        let _ = print("[ContentView] onAppear => RootContainerView displayed")
                    }
            }
        }
    }
}
