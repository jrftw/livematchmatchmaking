//
//  RootContainerView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - RootContainerView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A container with a bottom bar, switching to various screens. No mock data.
// Uses Firestore or Auth to load a real MyUserProfile. If none, checks if user is a guest.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct RootContainerView: View {
    
    // MARK: - MainScreen
    @State private var selectedScreen: MainScreen = .menu
    
    // MARK: - Init
    public init() {
        print("[RootContainerView] init called.")
        print("[RootContainerView] Initial selectedScreen: \(selectedScreen)")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[RootContainerView] body invoked. Building container with BottomBarView.")
        
        return ZStack(alignment: .bottom) {
            let _ = print("[RootContainerView] Inserting screenContent with bottom padding.")
            screenContent
                .padding(.bottom, 60)
            
            let _ = print("[RootContainerView] Adding BottomBarView.")
            BottomBarView(selectedScreen: $selectedScreen)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Screen Content
    @ViewBuilder
    private var screenContent: some View {
        let _ = print("[RootContainerView] screenContent computed. Selected screen: \(selectedScreen)")
        
        switch selectedScreen {
        case .menu:
            let _ = print("[RootContainerView] Selected screen => .menu. Building MainMenuView inside NavigationView.")
            NavigationView {
                MainMenuView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .feed:
            let _ = print("[RootContainerView] Selected screen => .feed. Building FeedView inside NavigationView.")
            NavigationView {
                FeedView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Feed")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .messages:
            let _ = print("[RootContainerView] Selected screen => .messages. Building MessagesHomeView inside NavigationView.")
            NavigationView {
                MessagesHomeView()
                    .navigationTitle("Messages")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .profile:
            let _ = print("[RootContainerView] Selected screen => .profile. Building ProfileHomeView with loadCurrentUserProfile.")
            NavigationView {
                ProfileHomeView(profile: loadCurrentUserProfile())
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Profile")
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // MARK: - Load Current User
    private func loadCurrentUserProfile() -> MyUserProfile {
        print("[RootContainerView] loadCurrentUserProfile called. Checking FirebaseAuth currentUser.")
        
        if let firebaseUser = Auth.auth().currentUser {
            print("[RootContainerView] A valid Firebase user exists: \(firebaseUser.uid). Creating MyUserProfile from user data.")
            // Replace this with your actual Firestore fetch or AuthManager logic if needed.
            return MyUserProfile(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? "",
                email: firebaseUser.email,
                bio: ""
            )
        } else {
            print("[RootContainerView] No current user. Checking guest fallback.")
            // If guest or truly no user, provide a minimal guest user.
            return MyUserProfile(
                id: nil,
                name: "Guest",
                bio: "Guest user"
            )
        }
    }
}
