// MARK: - PublicProfileView.swift
// Cleaned up, showing a centered banner and profile, plus real user posts.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PublicProfileView: View {
    public let profile: MyUserProfile
    public let isCurrentUser: Bool
    
    @StateObject private var postVM: ProfilePostsViewModel
    
    @State private var showingEditSheet = false
    
    public init(profile: MyUserProfile, isCurrentUser: Bool = false) {
        self.profile = profile
        self.isCurrentUser = isCurrentUser
        _postVM = StateObject(wrappedValue: ProfilePostsViewModel(userId: profile.id))
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // MARK: - Banner (Centered)
                ZStack {
                    if let bannerURL = profile.bannerURL,
                       !bannerURL.isEmpty,
                       let url = URL(string: bannerURL) {
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
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: 220)
                .clipped()
                
                // MARK: - Profile Picture (Centered)
                ZStack {
                    Circle().fill(Color.white)
                        .frame(width: 130, height: 130)
                    
                    if let picURL = profile.profilePictureURL,
                       !picURL.isEmpty,
                       let url = URL(string: picURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Circle().fill(Color.gray.opacity(0.3))
                            case .success(let img):
                                img.resizable().scaledToFill()
                            case .failure:
                                Circle().fill(Color.gray.opacity(0.3))
                            @unknown default:
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                        }
                        .clipShape(Circle())
                    } else {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 130, height: 130)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 3)
                )
                .offset(y: -65)
                .padding(.bottom, -65)
                
                // MARK: - Clan Tag + Username
                VStack(spacing: 4) {
                    if let clan = profile.clanTag, !clan.isEmpty {
                        Text("\(clan) @\(profile.username)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    } else {
                        Text("@\(profile.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 8)
                
                // MARK: - Bio
                if let b = profile.bio, !b.isEmpty {
                    Text(b)
                        .font(.body)
                        .padding(.top, 4)
                }
                
                // MARK: - Display Name
                Text(profile.displayName.isEmpty ? "Unknown" : profile.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                // MARK: - Followers / Following
                HStack(spacing: 32) {
                    VStack {
                        Text("\(profile.followersCount)")
                            .font(.headline)
                        Text("Followers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("\(profile.followingCount)")
                            .font(.headline)
                        Text("Following")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
                
                // MARK: - Win/Lose Stats
                let ratio = profile.losses == 0
                    ? (profile.wins > 0 ? "∞" : "0.0")
                    : String(format: "%.2f", Double(profile.wins) / Double(profile.losses))
                
                VStack(spacing: 2) {
                    Text("W/L Stats").font(.headline)
                    Text("Wins: \(profile.wins), Losses: \(profile.losses), Ratio: \(ratio)")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                // MARK: - Action Buttons
                HStack(spacing: 20) {
                    if isCurrentUser {
                        Button("Edit Profile") { showingEditSheet = true }
                            .font(.headline)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        Button("Share") {}
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Button("Follow") {
                            FollowService.shared.followUser(targetUserId: profile.id ?? "") { _ in }
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Message") {}
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 16)
                
                additionalInfoSection()
                
                // MARK: - Feed (Real User Posts)
                VStack(alignment: .leading, spacing: 6) {
                    Text(isCurrentUser ? "My Posts" : "\(profile.username)'s Posts")
                        .font(.headline)
                        .padding(.top, 20)
                    
                    if postVM.posts.isEmpty {
                        Text("No posts yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(postVM.posts) { post in
                            PostRowView(post: post)
                            Divider()
                        }
                    }
                }
                .padding(.top, 8)
                
                Spacer(minLength: 32)
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(isCurrentUser ? "My Profile" : "\(profile.username)'s Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: profile)
        }
    }
    
    private func additionalInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let bday = profile.birthday,
               profile.birthdayPublicly,
               !bday.isEmpty {
                Text("Birthday: \(bday)").foregroundColor(.secondary)
            }
            if let mail = profile.email,
               profile.emailPublicly,
               !mail.isEmpty {
                Text("Email: \(mail)").foregroundColor(.secondary)
            }
            if let ph = profile.phoneNumber,
               profile.phonePublicly,
               !ph.isEmpty {
                Text("Phone: \(ph)").foregroundColor(.secondary)
            }
            
            if !profile.tags.isEmpty {
                Text("Tags: \(profile.tags.joined(separator: ", "))")
                    .foregroundColor(.secondary)
            }
            
            if !profile.socialLinks.isEmpty {
                ForEach(Array(profile.socialLinks.keys), id: \.self) { key in
                    if let link = profile.socialLinks[key], !link.isEmpty {
                        Text("\(key): \(link)")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }
}
