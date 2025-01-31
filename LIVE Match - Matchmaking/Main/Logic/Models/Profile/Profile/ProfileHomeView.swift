//
//  ProfileHomeView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays the current user's profile, with edit capability.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileHomeView: View {
    @StateObject private var vm = ProfileHomeViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if let profile = vm.profile {
                    VStack(spacing: 20) {
                        ProfileDetailView(profile: profile)
                            .padding(.horizontal)
                        
                        if profile.id == Auth.auth().currentUser?.uid {
                            NavigationLink("Edit Profile") {
                                EditProfileView(viewModel: vm, profile: profile)
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    Text("Loading Profile...")
                        .font(.headline)
                        .padding()
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { vm.logout() }) {
                        Text("Logout")
                    }
                }
            }
            .onAppear {
                vm.fetchProfile()
            }
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
                    username: "Guest User",
                    accountTypes: [.guest],
                    email: nil,
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
                    createdAt: Date(),
                    hasCommunityMembership: false,
                    isCommunityAdmin: false,
                    hasGroupMembership: false,
                    isGroupAdmin: false,
                    hasTeamMembership: false,
                    isTeamAdmin: false,
                    hasAgencyMembership: false,
                    isAgencyAdmin: false,
                    hasCreatorNetworkMembership: false,
                    isCreatorNetworkAdmin: false
                )
            }
            return
        }
        
        db.collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            guard error == nil else {
                print("ProfileHomeViewModel error: \(error!.localizedDescription)")
                return
            }
            guard let doc = documentSnapshot else {
                print("No snapshot found; user doc may not exist.")
                self.profile = UserProfile(
                    id: uid,
                    username: "No Profile Yet",
                    accountTypes: [.guest],
                    email: nil,
                    bio: "",
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
                    createdAt: Date(),
                    hasCommunityMembership: false,
                    isCommunityAdmin: false,
                    hasGroupMembership: false,
                    isGroupAdmin: false,
                    hasTeamMembership: false,
                    isTeamAdmin: false,
                    hasAgencyMembership: false,
                    isAgencyAdmin: false,
                    hasCreatorNetworkMembership: false,
                    isCreatorNetworkAdmin: false
                )
                return
            }
            if !doc.exists {
                self.profile = UserProfile(
                    id: uid,
                    username: "No Profile Yet",
                    accountTypes: [.guest],
                    email: nil,
                    bio: "",
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
                    createdAt: Date(),
                    hasCommunityMembership: false,
                    isCommunityAdmin: false,
                    hasGroupMembership: false,
                    isGroupAdmin: false,
                    hasTeamMembership: false,
                    isTeamAdmin: false,
                    hasAgencyMembership: false,
                    isAgencyAdmin: false,
                    hasCreatorNetworkMembership: false,
                    isCreatorNetworkAdmin: false
                )
            } else {
                do {
                    let fetched = try doc.data(as: UserProfile.self)
                    self.profile = fetched
                } catch {
                    print("Error decoding user profile: \(error.localizedDescription)")
                    self.profile = UserProfile(
                        id: uid,
                        username: "Invalid doc data",
                        accountTypes: [.guest],
                        email: nil,
                        bio: "",
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
                        createdAt: Date(),
                        hasCommunityMembership: false,
                        isCommunityAdmin: false,
                        hasGroupMembership: false,
                        isGroupAdmin: false,
                        hasTeamMembership: false,
                        isTeamAdmin: false,
                        hasAgencyMembership: false,
                        isAgencyAdmin: false,
                        hasCreatorNetworkMembership: false,
                        isCreatorNetworkAdmin: false
                    )
                }
            }
        }
    }
    
    public func updateProfile(_ profile: UserProfile) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(uid).setData(from: profile)
            self.profile = profile
        } catch {
            print("Failed to update profile: \(error.localizedDescription)")
        }
    }
    
    public func logout() {
        do {
            try Auth.auth().signOut()
            AuthManager.shared.isGuest = true
            self.profile = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
