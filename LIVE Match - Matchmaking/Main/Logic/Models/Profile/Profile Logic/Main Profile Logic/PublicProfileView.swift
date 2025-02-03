// MARK: - PublicProfileView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PublicProfileView: View {
    public let profile: MyUserProfile
    public let isCurrentUser: Bool
    
    @State private var userPosts: [String] = [
        "Public post #1",
        "Public post #2",
        "Public post #3"
    ]
    @State private var showingEditSheet = false
    
    public init(profile: MyUserProfile, isCurrentUser: Bool = false) {
        self.profile = profile
        self.isCurrentUser = isCurrentUser
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                bannerSection()
                VStack(spacing: 16) {
                    avatarAndBasicInfo()
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
    
    private func bannerSection() -> some View {
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
                .frame(height: 180)
                .clipped()
            } else {
                Color.gray.opacity(0.3).frame(height: 180)
            }
        }
    }
    
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
    
    private func aboutSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let b = profile.bio, !b.isEmpty {
                Text(b).font(.body)
            }
            if let ph = profile.phoneNumber, !ph.isEmpty {
                Text("Phone: \(ph)").foregroundColor(.secondary)
            }
            if let bday = profile.birthday, !bday.isEmpty {
                Text("Birthday: \(bday)").foregroundColor(.secondary)
            }
            if let mail = profile.email, !mail.isEmpty {
                Text("Email: \(mail)").foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
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
    
    @ViewBuilder
    private func feedSection() -> some View {
        Text(isCurrentUser ? "My Feed" : "\(profile.username)'s Posts")
            .font(.headline)
            .padding(.top, 16)
        
        if userPosts.isEmpty {
            Text("No posts yet.")
                .foregroundColor(.secondary)
        } else {
            ForEach(userPosts, id: \.self) { post in
                VStack(alignment: .leading, spacing: 6) {
                    Text(post)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
        }
    }
}
