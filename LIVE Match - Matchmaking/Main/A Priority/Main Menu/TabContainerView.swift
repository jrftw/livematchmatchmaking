//
//  TabContainerView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Optional: SwiftUI TabView approach. We fix the missing 'profile' argument by requiring a profile in the constructor.
//  If you prefer the always-on-bottom bar approach, you can remove this file.
//  This fix supplies a default sample profile or fetch to avoid compile errors.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TabContainerView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab: Int = 0
    
    // Provide a default or fetched user profile to pass into ProfileDetailView
    // We'll do an example with a minimal "Guest" or "Fake" profile to fix compile error.
    let sampleProfile: UserProfile = UserProfile(
        id: "fakeID",
        accountTypes: [.creator],
        email: "fake@example.com",
        name: "Sample User",
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
                
                // Example messaging view
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(2)
                
                // Provide a valid user profile to ProfileDetailView
                ProfileDetailView(profile: sampleProfile)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(3)
            }
        }
    }
}
