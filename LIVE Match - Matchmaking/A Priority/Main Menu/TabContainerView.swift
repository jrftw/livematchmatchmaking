//
//  TabContainerView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  A TabView with MainMenu, Feed, Messages, and Profile. If user != nil or isGuest,
//  displays the additional tabs. For Profile, we pass the user’s UID to ProfileHomeView
//  so it loads the real Firestore data, with no test/placeholder fields.
//
import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TabContainerView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // If MainMenuView requires a selectedScreen binding,
            // we provide a default .constant(.menu) or other binding:
            MainMenuView(selectedScreen: .constant(.menu))
                .tabItem {
                    Label("Main Menu", systemImage: "house.fill")
                }
                .tag(0)
            
            // If user or isGuest, show feed, messages, and profile
            if authManager.user != nil || authManager.isGuest {
                
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(1)
                
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(2)
                
                // Pass the real user’s UID to ProfileHomeView.
                // If user is nil but isGuest == true, pass nil so ProfileHomeView
                // can handle fallback logic internally.
                ProfileHomeView(userID: authManager.user?.uid)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(3)
            }
        }
    }
}
