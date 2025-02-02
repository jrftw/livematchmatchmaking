//
//  MyUserProfileView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - MyUserProfileView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays the current user's profile using MyUserProfile, with an Edit button
// that opens EditProfileView in a sheet. It converts MyUserProfile -> UserProfile.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MyUserProfileView: View {
    
    // MARK: - Properties
    public let profile: MyUserProfile
    
    @State private var userPosts: [String] = [
        "My post #1",
        "My post #2",
        "My post #3"
    ]
    @State private var showingEditSheet = false
    
    // MARK: - Init
    public init(profile: MyUserProfile) {
        self.profile = profile
    }
    
    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                bannerSection()
                headerSection()
                statsRow()
                accountInfoSection()
                tagsSection()
                feedSection()
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: profile.asUserProfile())
        }
    }
    
    // MARK: - Banner
    private func bannerSection() -> some View {
        Group {
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
        }
    }
    
    // MARK: - Header
    private func headerSection() -> some View {
        HStack(spacing: 16) {
            if let picURL = profile.profilePictureURL,
               !picURL.isEmpty,
               let url = URL(string: picURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name.isEmpty ? "Unknown" : profile.name)
                    .font(.headline)
                if let clanTag = profile.clanTag, !clanTag.isEmpty {
                    Text("Clan: \(clanTag)")
                        .font(.subheadline)
                }
            }
            Spacer()
            
            Menu {
                Button("Edit Profile") {
                    showingEditSheet = true
                }
                Button("Share Profile") {
                    // Implementation to share, if needed
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Stats
    private func statsRow() -> some View {
        HStack(spacing: 20) {
            VStack {
                Text("Followers").font(.subheadline)
                Text("\(profile.followers)").font(.headline)
            }
            VStack {
                Text("Following").font(.subheadline)
                let followingCount = profile.friends
                Text("\(followingCount)").font(.headline)
            }
            VStack {
                Text("Friends").font(.subheadline)
                Text("\(profile.friends)").font(.headline)
            }
            VStack {
                Text("Wins/Losses").font(.subheadline)
                Text("\(profile.wins)/\(profile.losses)").font(.headline)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Account Info
    @ViewBuilder
    private func accountInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if profile.accountTypes.isEmpty {
                Text("Account Type: Guest").font(.subheadline)
            } else {
                let types = profile.accountTypes
                    .map { $0.rawValue.capitalized }
                    .joined(separator: ", ")
                Text("Account Type: \(types)").font(.subheadline)
            }
            if !profile.bio.isEmpty {
                Text("Bio: \(profile.bio)").font(.subheadline)
            }
            if let year = profile.birthYear, !year.isEmpty {
                Text("Birth Year: \(year)").font(.subheadline)
            }
            if let email = profile.email, !email.isEmpty {
                Text("Email: \(email)").font(.subheadline)
            }
            if let phone = profile.phone, !phone.isEmpty {
                Text("Phone: \(phone)").font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Tags
    private func tagsSection() -> some View {
        Group {
            if !profile.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags:").font(.headline)
                    Text(profile.tags.joined(separator: ", "))
                        .font(.subheadline)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Feed
    private func feedSection() -> some View {
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
