//
//  TabContainerView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - TabContainerView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A simple TabView demonstration if you prefer tabs instead of a custom bottom bar.
// No mock data; a real MyUserProfile is used if user is logged in, or "Guest" otherwise.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TabContainerView: View {
    
    // MARK: - Auth Manager
    @StateObject private var authManager = AuthManager.shared
    
    // MARK: - Selected Tab
    @State private var selectedTab: Int = 0
    
    // MARK: - Init
    public init() {
        print("[TabContainerView] init called.")
        print("[TabContainerView] Initial selectedTab: \(selectedTab)")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[TabContainerView] body invoked. Building TabView.")
        
        return TabView(selection: $selectedTab) {
            // Always show Main Menu
            let _ = print("[TabContainerView] Adding MainMenuView to TabView with tag 0.")
            MainMenuView()
                .tabItem {
                    Label("Main Menu", systemImage: "house.fill")
                }
                .tag(0)
            
            // Conditionally show Feed tab
            if authManager.user != nil || authManager.isGuest {
                let _ = print("[TabContainerView] User is logged in or guest. Adding Feed tab.")
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(1)
            } else {
                let _ = print("[TabContainerView] User is nil and not guest. Feed tab not added.")
            }
            
            // Conditionally show Messages tab
            if authManager.user != nil || authManager.isGuest {
                let _ = print("[TabContainerView] User is logged in or guest. Adding Messages tab.")
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(2)
            } else {
                let _ = print("[TabContainerView] User is nil and not guest. Messages tab not added.")
            }
            
            // Conditionally show Profile tab
            if authManager.user != nil || authManager.isGuest {
                let _ = print("[TabContainerView] User is logged in or guest. Adding Profile tab.")
                ProfileHomeView(profile: loadCurrentUserProfile())
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(3)
            } else {
                let _ = print("[TabContainerView] User is nil and not guest. Profile tab not added.")
            }
        }
    }
    
    // MARK: - Load Current User Profile
    private func loadCurrentUserProfile() -> MyUserProfile {
        print("[TabContainerView] loadCurrentUserProfile called. Checking auth state.")
        
        if let firebaseUser = authManager.user {
            print("[TabContainerView] Found valid Firebase user: \(firebaseUser.uid)")
            return MyUserProfile(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? "",
                email: firebaseUser.email,
                bio: ""
            )
        } else if authManager.isGuest {
            print("[TabContainerView] No user found, but isGuest == true. Returning guest profile.")
            return MyUserProfile(
                id: nil,
                name: "Guest",
                bio: "Guest user"
            )
        } else {
            print("[TabContainerView] No user found, not guest. Returning unknown profile.")
            return MyUserProfile(
                id: nil,
                name: "Unknown",
                bio: ""
            )
        }
    }
}
