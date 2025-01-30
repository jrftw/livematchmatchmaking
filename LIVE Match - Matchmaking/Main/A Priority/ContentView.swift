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
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        if authManager.user == nil && !authManager.isGuest {
            WelcomeView()
        } else {
            RootContainerView()
        }
    }
}
