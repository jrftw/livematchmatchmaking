//
//  ProfileHomeView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A view that loads the user's profile from Firestore and displays or allows edit.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileHomeView: View {
    @StateObject private var vm = ProfileHomeViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack {
            if let profile = vm.profile {
                if profile.id == Auth.auth().currentUser?.uid {
                    VStack(spacing: 20) {
                        ProfileDetailView(profile: profile)
                        NavigationLink("Edit Profile") {
                            EditProfileView(profile: profile)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ProfileDetailView(profile: profile)
                }
            } else {
                Text("Loading Profile...")
            }
        }
        .onAppear {
            vm.fetchProfile()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ProfileHomeViewModel: ObservableObject {
    @Published public var profile: UserProfile?
    private let db = FirebaseManager.shared.db
    
    public init() {}
    
    public func fetchProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            if AuthManager.shared.isGuest {
                self.profile = UserProfile(
                    id: nil,
                    accountTypes: [.guest],
                    email: nil,
                    name: "Guest User",
                    bio: "Limited features",
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
            }
            return
        }
        db.collection("users").document(uid).addSnapshotListener { doc, _ in
            guard let doc = doc else { return }
            do {
                let result = try doc.data(as: UserProfile.self)
                self.profile = result
            } catch {
                print("Error fetching user profile: \(error)")
            }
        }
    }
}
