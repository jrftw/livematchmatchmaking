// MARK: File: ProfileHomeView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays user’s profile, allows editing if it's the current user.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct ProfileHomeView: View {
    @StateObject private var vm = ProfileHomeViewModel()
    public init() {}
    
    public var body: some View {
        VStack {
            if let profile = vm.profile {
                if profile.id == Auth.auth().currentUser?.uid {
                    NavigationView {
                        VStack(spacing: 20) {
                            ProfileDetailView(profile: profile)
                            NavigationLink("Edit Profile") {
                                EditProfileView(profile: profile)
                            }
                            .padding(.horizontal)
                        }
                        .navigationTitle("My Profile")
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
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
                    bio: "Limited features for guests",
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
                print("Error fetching user profile: \(error.localizedDescription)")
            }
        }
    }
}

public struct ProfileDetailView: View {
    public let profile: UserProfile
    
    public init(profile: UserProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(profile.name.isEmpty ? "No Name" : profile.name)
                    .font(.title)
                
                if let banner = profile.bannerURL, !banner.isEmpty {
                    AsyncImage(url: URL(string: banner)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                }
                
                if let pic = profile.profilePictureURL, !pic.isEmpty {
                    AsyncImage(url: URL(string: pic)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                }
                
                Text(profile.bio)
                    .padding(.horizontal)
                
                let typeList = profile.accountTypes.map { $0.rawValue.capitalized }.joined(separator: ", ")
                Text("Account Types: \(typeList)")
                
                if !profile.tags.isEmpty {
                    Text("Tags: \(profile.tags.joined(separator: ", "))")
                }
                
                Text("Followers: \(profile.followers)")
                Text("Friends: \(profile.friends)")
                Text("Wins: \(profile.wins) | Losses: \(profile.losses)")
                
                if let clan = profile.clanTag, !clan.isEmpty {
                    Text("Clan: \(clan)")
                }
                if let est = profile.establishedDate, !est.isEmpty {
                    Text("Established: \(est)")
                }
                
                List {
                    Section("Old-Style Social Links") {
                        ForEach(profile.socialLinks, id: \.self) { link in
                            Text(link)
                        }
                    }
                    Section("Old-Style Gaming Accounts") {
                        ForEach(profile.gamingAccounts, id: \.self) { ga in
                            Text(ga)
                        }
                    }
                    Section("Old-Style Live Platforms") {
                        ForEach(profile.livePlatforms, id: \.self) { lp in
                            Text(lp)
                        }
                    }
                    Section("New Gaming Account Details") {
                        ForEach(profile.gamingAccountDetails, id: \.id) { ga in
                            VStack(alignment: .leading) {
                                Text("Username: \(ga.username)")
                                if !ga.teamsOrCommunities.isEmpty {
                                    Text("Teams/Communities: \(ga.teamsOrCommunities.joined(separator: ", "))")
                                }
                            }
                        }
                    }
                    Section("New LIVE Platform Details") {
                        ForEach(profile.livePlatformDetails, id: \.id) { lp in
                            VStack(alignment: .leading) {
                                Text("Username: \(lp.username)")
                                Text("Link: \(lp.link)")
                                if let net = lp.agencyOrCreatorNetwork {
                                    Text("Agency/Creator Network: \(net)")
                                }
                                if !lp.teamsOrCommunities.isEmpty {
                                    Text("Teams/Communities: \(lp.teamsOrCommunities.joined(separator: ", "))")
                                }
                            }
                        }
                    }
                }
                .frame(minHeight: 300)
            }
        }
    }
}
