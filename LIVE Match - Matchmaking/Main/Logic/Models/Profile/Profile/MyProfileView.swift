//
//  MyProfileView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A profile view for showing the user’s own profile in a detailed layout.
//  Displays banner, profile picture, stats (followers/friends/wins/losses), clan tag,
//  plus optional fields (birth year, phone, email, tags, etc.).
//  Includes an “Edit Profile” and “Share Profile” menu, and a user-only feed section.
//
//  Note: Replaced 'profile.username' references with 'profile.name' since MyUserProfile
//  does not define a 'username' field. If you need a separate username property, add it
//  to MyUserProfile and reference it accordingly.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MyProfileView: View {
    // The user’s own profile data
    public let profile: MyUserProfile
    
    // Feed posts just for this user (placeholder)
    @State private var userPosts: [String] = [
        "Enjoying the new #LIVEMatch features!",
        "Just joined a new clan!",
        "Won my last bracket match #Gamer"
    ]
    
    // Show a menu of actions like editing or sharing
    @State private var showingMenu = false
    
    public init(profile: MyUserProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // MARK: - Banner
                if let bannerURL = profile.bannerURL,
                   !bannerURL.isEmpty,
                   let url = URL(string: bannerURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(maxHeight: 180)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(maxHeight: 180)
                }
                
                // MARK: - Profile Picture & Basic Info
                HStack(spacing: 16) {
                    if let picURL = profile.profilePictureURL,
                       !picURL.isEmpty,
                       let url = URL(string: picURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Use MyUserProfile.name here
                        Text(profile.name.isEmpty ? "Unknown" : profile.name)
                            .font(.headline)
                        
                        // Clan Tag
                        if let clanTag = profile.clanTag, !clanTag.isEmpty {
                            Text("Clan: \(clanTag)")
                                .font(.subheadline)
                        }
                    }
                    Spacer()
                    
                    // Small menu button
                    Button {
                        showingMenu.toggle()
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .rotationEffect(.degrees(90))
                    }
                    .contextMenu(menuItems: {
                        Button("Edit Profile") {
                            // Implementation for edit
                            print("Edit profile tapped")
                        }
                        Button("Share Profile") {
                            // Implementation for share
                            print("Share profile tapped")
                        }
                    })
                }
                .padding(.horizontal)
                
                // MARK: - Stats Row
                HStack(spacing: 20) {
                    VStack {
                        Text("Followers")
                            .font(.subheadline)
                        Text("\(profile.followers)")
                            .font(.headline)
                    }
                    VStack {
                        Text("Following")
                            .font(.subheadline)
                        // We don’t explicitly store “following” count, you can adapt
                        let followingCount = profile.friends // or custom logic
                        Text("\(followingCount)")
                            .font(.headline)
                    }
                    VStack {
                        Text("Friends")
                            .font(.subheadline)
                        Text("\(profile.friends)")
                            .font(.headline)
                    }
                    VStack {
                        Text("Wins/Losses")
                            .font(.subheadline)
                        Text("\(profile.wins) / \(profile.losses)")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Account Info
                accountInfoSection()
                
                // MARK: - Tags
                if !profile.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags:")
                            .font(.headline)
                        Text(profile.tags.joined(separator: ", "))
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - My Feed
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Feed").font(.headline)
                    ForEach(userPosts, id: \.self) { post in
                        Text(post)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Account Info Section
    @ViewBuilder
    private func accountInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if profile.accountTypes.isEmpty {
                Text("Account Type: Guest")
                    .font(.subheadline)
            } else {
                let types = profile.accountTypes.map { $0.rawValue.capitalized }.joined(separator: ", ")
                Text("Account Type: \(types)")
                    .font(.subheadline)
            }
            
            // Bio
            if !profile.bio.isEmpty {
                Text("Bio: \(profile.bio)")
                    .font(.subheadline)
            }
            
            // Birth year
            if let year = profile.birthYear, !year.isEmpty {
                Text("Birth Year: \(year)")
                    .font(.subheadline)
            }
            
            // Email
            if let email = profile.email, !email.isEmpty {
                Text("Email: \(email)")
                    .font(.subheadline)
            }
            
            // Phone
            if let phone = profile.phone, !phone.isEmpty {
                Text("Phone: \(phone)")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
}
