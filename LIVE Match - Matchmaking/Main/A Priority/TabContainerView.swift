//
//  TabContainerView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Alternative approach using SwiftUI's TabView. You can safely remove this file if you prefer BottomBarView.
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
            MainMenuView()
                .tabItem {
                    Label("Main Menu", systemImage: "house.fill")
                }
                .tag(0)
            
            if authManager.user != nil || authManager.isGuest {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(1)
                
                // Direct or advanced messaging approach
                MessagesHomeView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(2)
                
                ProfileHomeView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(3)
            }
        }
    }
}
