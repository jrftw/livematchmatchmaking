//
//  ProfileHomeView.swift (Updated)
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Places Sign Out at the bottom of the user's profile, visible when the user owns that profile.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct ProfileHomeView: View {
    @StateObject private var vm = ProfileHomeViewModel()
    public init() {}
    
    public var body: some View {
        VStack {
            if let profile = vm.profile {
                // If we are the profile owner
                if profile.id == Auth.auth().currentUser?.uid || AuthManager.shared.isGuest {
                    NavigationView {
                        VStack(spacing: 20) {
                            ProfileDetailView(profile: profile)
                            NavigationLink("Edit Profile") {
                                EditProfileView(profile: profile)
                            }
                            .padding(.horizontal)
                            
                            // Sign Out button at the bottom
                            Button("Sign Out") {
                                AuthManager.shared.signOut()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.bottom, 30)
                            
                        }
                        .navigationTitle("My Profile")
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    // If we're viewing someone else's profile
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
