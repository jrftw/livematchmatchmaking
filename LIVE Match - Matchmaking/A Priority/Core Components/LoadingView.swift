//
//  LoadingView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

import SwiftUI
import FirebaseAuth

struct LoadingView: View {
    // MARK: - State
    @State private var isLoggedIn = false
    @State private var isLoading = true
    
    // MARK: - Init
    init() {
        print("[LoadingView] init called.")
        print("[LoadingView] isLoggedIn: \(isLoggedIn), isLoading: \(isLoading)")
    }
    
    // MARK: - Body
    var body: some View {
        let _ = print("[LoadingView] body invoked. isLoggedIn: \(isLoggedIn), isLoading: \(isLoading)")
        
        return Group {
            if isLoading {
                let _ = print("[LoadingView] Condition => isLoading is true. Showing ProgressView.")
                ProgressView("Loading...")
            } else {
                if isLoggedIn {
                    let _ = print("[LoadingView] Condition => isLoading is false & isLoggedIn is true. Navigating to MainMenuView.")
                    MainMenuView()
                        .onAppear {
                            print("[LoadingView] onAppear triggered for MainMenuView.")
                        }
                } else {
                    let _ = print("[LoadingView] Condition => isLoading is false & isLoggedIn is false. Navigating to LoginView.")
                    LoginView()
                        .onAppear {
                            print("[LoadingView] onAppear triggered for LoginView.")
                        }
                }
            }
        }
        .onAppear {
            print("[LoadingView] onAppear triggered. Calling checkAuthStatus().")
            checkAuthStatus()
        }
    }
    
    // MARK: - Check Auth Status
    func checkAuthStatus() {
        print("[LoadingView] checkAuthStatus called.")
        if let currentUser = Auth.auth().currentUser {
            print("[LoadingView] User is logged in. Current user: \(currentUser.email ?? "Unknown Email")")
            isLoggedIn = true
        } else {
            print("[LoadingView] No user found. Not logged in.")
        }
        
        isLoading = false
        print("[LoadingView] checkAuthStatus completed. isLoggedIn: \(isLoggedIn), isLoading: \(isLoading)")
    }
}
