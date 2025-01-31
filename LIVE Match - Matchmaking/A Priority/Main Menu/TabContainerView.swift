// File: TabContainerView.swift
// MARK: TabContainerView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TabContainerView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab: Int = 0
    
    let sampleProfile: UserProfile = UserProfile(
        id: "fakeID",
        username: "Sample User",
        accountTypes: [.creator],
        email: "fake@example.com",
        bio: "This is a sample user profile",
        birthYear: nil,
        phone: nil,
        profilePictureURL: nil,
        bannerURL: nil,
        clanTag: nil,
        tags: [],
        socialLinks: [],
        gamingAccounts: [],
        livePlatforms: [],
        gamingAccountDetails: [],
        livePlatformDetails: [],
        followers: 0,
        friends: 0,
        isSearching: false,
        wins: 0,
        losses: 0,
        roster: [],
        establishedDate: nil,
        subscriptionActive: false,
        subscriptionPrice: 0,
        createdAt: Date()
    )
    
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
                
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(2)
                
                ProfileDetailView(profile: sampleProfile)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(3)
            }
        }
    }
}
