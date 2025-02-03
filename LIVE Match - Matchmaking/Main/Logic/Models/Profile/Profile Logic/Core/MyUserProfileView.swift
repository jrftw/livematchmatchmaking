// MARK: - MyUserProfileView.swift
// Displays a MyUserProfile in a simple scrollable view.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MyUserProfileView: View {
    public let profile: MyUserProfile
    @State private var showingEditSheet = false
    
    public init(profile: MyUserProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                bannerSection()
                headerSection()
                accountInfoSection()
                tagsSection()
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: profile)
        }
    }
    
    private func bannerSection() -> some View {
        Group {
            if let bannerURL = profile.bannerURL,
               !bannerURL.isEmpty,
               let url = URL(string: bannerURL) {
                AsyncImage(url: url) { imagePhase in
                    switch imagePhase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let img):
                        img.resizable().scaledToFit()
                    case .failure:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(maxHeight: 180)
            } else {
                Color.gray.opacity(0.3).frame(maxHeight: 180)
            }
        }
    }
    
    private func headerSection() -> some View {
        HStack(spacing: 16) {
            if let picURL = profile.profilePictureURL,
               !picURL.isEmpty,
               let url = URL(string: picURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let loaded):
                        loaded.resizable().scaledToFill()
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
                Text(profile.displayName.isEmpty ? "Unknown" : profile.displayName)
                    .font(.headline)
                
                if let clan = profile.clanTag, !clan.isEmpty {
                    Text("Clan: \(clan)").font(.subheadline)
                }
            }
            Spacer()
            
            Menu {
                Button("Edit Profile") {
                    showingEditSheet = true
                }
                Button("Share Profile") {
                    // Implementation if needed
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal)
    }
    
    private func accountInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let b = profile.bio, !b.isEmpty {
                Text("Bio: \(b)").font(.subheadline)
            }
            if let bday = profile.birthday, !bday.isEmpty {
                Text("Birthday: \(bday)").font(.subheadline)
            }
            if let em = profile.email, !em.isEmpty {
                Text("Email: \(em)").font(.subheadline)
            }
            if let ph = profile.phoneNumber, !ph.isEmpty {
                Text("Phone: \(ph)").font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func tagsSection() -> some View {
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
