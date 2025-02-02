//
//  PublicProfileView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - PublicProfileView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays any user's public profile. If it's the current user,
// shows an Edit button that opens EditProfileView in a sheet.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PublicProfileView: View {
    
    // MARK: - Properties
    public let profile: UserProfile
    public let isCurrentUser: Bool
    @State private var userPosts: [String] = [
        "Public post #1",
        "Public post #2",
        "Public post #3"
    ]
    @State private var showingEditSheet = false
    
    // MARK: - Init
    public init(profile: UserProfile, isCurrentUser: Bool = false) {
        self.profile = profile
        self.isCurrentUser = isCurrentUser
    }
    
    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                bannerSection()
                VStack(spacing: 16) {
                    avatarAndBasicInfo()
                    statsRow()
                    actionButtonsRow()
                    aboutSection()
                    tagsSection()
                    feedSection()
                }
                .padding(.top, -40)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .offset(y: -30)
                )
                .padding(.top, -30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(isCurrentUser ? "My Profile" : "\(profile.username)'s Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: profile)
        }
    }
    
    // MARK: - Banner
    private func bannerSection() -> some View {
        ZStack {
            if let bannerURL = profile.bannerURL,
               !bannerURL.isEmpty,
               let url = URL(string: bannerURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: Color.gray.opacity(0.3)
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Color.gray.opacity(0.3)
                    @unknown default: Color.gray.opacity(0.3)
                    }
                }
                .frame(height: 180)
                .clipped()
            } else {
                Color.gray.opacity(0.3).frame(height: 180)
            }
        }
    }
    
    // MARK: - Avatar & Info
    private func avatarAndBasicInfo() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let picURL = profile.profilePictureURL,
                   !picURL.isEmpty,
                   let url = URL(string: picURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure:
                            Circle().fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                        @unknown default:
                            Circle().fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                        }
                    }
                } else {
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
            }
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .offset(y: -40)
            .padding(.bottom, -40)
            
            Text(profile.username.isEmpty ? "Unknown" : profile.username)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let clanTag = profile.clanTag, !clanTag.isEmpty {
                Text("Clan: \(clanTag)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Stats
    private func statsRow() -> some View {
        HStack(spacing: 24) {
            VStack {
                Text("Followers").font(.caption)
                Text("\(profile.followers)").font(.headline)
            }
            VStack {
                Text("Friends").font(.caption)
                Text("\(profile.friends)").font(.headline)
            }
            VStack {
                Text("Wins/Losses").font(.caption)
                Text("\(profile.wins)/\(profile.losses)").font(.headline)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Action Buttons
    private func actionButtonsRow() -> some View {
        Group {
            if isCurrentUser {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit Profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                HStack(spacing: 16) {
                    Button("Follow") {}
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Button("Message") {}
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - About
    private func aboutSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if !profile.bio.isEmpty {
                Text(profile.bio).font(.body)
            }
            if let phone = profile.phone, !phone.isEmpty {
                Text("Phone: \(phone)").foregroundColor(.secondary)
            }
            if let by = profile.birthYear, !by.isEmpty {
                Text("Birth Year: \(by)").foregroundColor(.secondary)
            }
            if let mail = profile.email, !mail.isEmpty {
                Text("Email: \(mail)").foregroundColor(.secondary)
            }
            if !profile.livePlatforms.isEmpty {
                Text("Live Platforms: \(profile.livePlatforms.joined(separator: ", "))")
                    .foregroundColor(.secondary)
            }
            if !profile.gamingAccounts.isEmpty {
                Text("Gaming Accounts: \(profile.gamingAccounts.joined(separator: ", "))")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    // MARK: - Tags
    @ViewBuilder
    private func tagsSection() -> some View {
        if !profile.tags.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tags").font(.headline)
                Text(profile.tags.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Feed
    private func feedSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isCurrentUser ? "My Feed" : "\(profile.username)'s Posts")
                .font(.headline)
            ForEach(userPosts, id: \.self) { post in
                VStack(alignment: .leading, spacing: 6) {
                    Text(post)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
        }
        .padding(.top, 16)
    }
}
