// MARK: - LoadingView.swift
// iOS 15.6+
// A quick splash or loading screen that checks Firebase Auth status.
// Wraps everything in a single `Group` expression, and uses `let _ = print(...)` for side effects.

import SwiftUI
import FirebaseAuth

struct LoadingView: View {
    @State private var isLoggedIn = false
    @State private var isLoading = true
    
    init() {
        let _ = print("[LoadingView] init called.")
        let _ = print("[LoadingView] isLoggedIn: \(isLoggedIn), isLoading: \(isLoading)")
    }
    
    var body: some View {
        // Wrap all logic in a single 'Group' so SwiftUI sees it as one expression
        Group {
            let _ = print("[LoadingView] body invoked. isLoggedIn: \(isLoggedIn), isLoading: \(isLoading)")
            
            if isLoading {
                let _ = print("[LoadingView] Condition => isLoading is true => showing ProgressView.")
                
                ProgressView("Loading...")
            } else {
                if isLoggedIn {
                    let _ = print("[LoadingView] Condition => isLoading false & isLoggedIn true => MainMenuView.")
                    
                    // If MainMenuView requires a Binding<MainScreen>, pass it here:
                    MainMenuView(selectedScreen: .constant(.menu))
                        .onAppear {
                            let _ = print("[LoadingView] onAppear => MainMenuView displayed.")
                        }
                } else {
                    let _ = print("[LoadingView] Condition => isLoading false & isLoggedIn false => LoginView.")
                    
                    // If LoginView requires a Binding<MainScreen>, pass it similarly
                    LoginView(selectedScreen: .constant(.menu))
                        .onAppear {
                            let _ = print("[LoadingView] onAppear => LoginView displayed.")
                        }
                }
            }
        }
        .onAppear {
            let _ = print("[LoadingView] onAppear => calling checkAuthStatus().")
            checkAuthStatus()
        }
    }
    
    private func checkAuthStatus() {
        let _ = print("[LoadingView] checkAuthStatus called.")
        
        if let currentUser = Auth.auth().currentUser {
            let _ = print("[LoadingView] Found logged-in user => \(currentUser.email ?? "Unknown Email").")
            isLoggedIn = true
        } else {
            let _ = print("[LoadingView] No user found => not logged in.")
        }
        
        isLoading = false
        let _ = print("[LoadingView] checkAuthStatus => completed. isLoggedIn: \(isLoggedIn), isLoading: \(isLoading)")
    }
}
