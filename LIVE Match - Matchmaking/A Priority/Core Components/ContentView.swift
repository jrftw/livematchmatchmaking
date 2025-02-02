//
//  ContentView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Entry point after splash. If user is neither logged in nor guest => WelcomeView()
//  Otherwise => RootContainerView with a persistent, clickable BottomBarView.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ContentView: View {
    // MARK: - ObservedObject
    @ObservedObject private var authManager = AuthManager.shared
    
    // MARK: - Init
    init() {
        print("[ContentView] init called. Current user: \(AuthManager.shared.user?.email ?? "nil"), isGuest: \(AuthManager.shared.isGuest)")
    }
    
    // MARK: - Body
    var body: some View {
        let _ = print("[ContentView] body invoked. Checking user state: \(authManager.user?.email ?? "nil"), isGuest: \(authManager.isGuest)")
        
        if authManager.user == nil && !authManager.isGuest {
            let _ = print("[ContentView] Condition => user is nil & isGuest is false. Navigating to WelcomeView.")
            WelcomeView()
                .onAppear {
                    print("[ContentView] onAppear triggered: WelcomeView is displayed.")
                }
        } else {
            let _ = print("[ContentView] Condition => user is not nil or isGuest is true. Navigating to RootContainerView.")
            RootContainerView()
                .onAppear {
                    print("[ContentView] onAppear triggered: RootContainerView is displayed.")
                }
        }
    }
}
