//
//  ProfileDetailView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Showcases a user profile in detail.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileDetailView: View {
    private let profile: UserProfile
    
    public init(profile: UserProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let banner = profile.bannerURL,
                   !banner.isEmpty,
                   let url = URL(string: banner) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(maxHeight: 150)
                } else {
                    Color.gray.opacity(0.3).frame(maxHeight: 150)
                }
                
                HStack(spacing: 16) {
                    if let picURL = profile.profilePictureURL,
                       let url = URL(string: picURL),
                       !picURL.isEmpty {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Circle().fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.username.isEmpty ? "Unknown" : profile.username)
                            .font(.headline)
                        
                        if let clan = profile.clanTag, !clan.isEmpty {
                            Text("Clan: \(clan)").font(.subheadline)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                if !profile.bio.isEmpty {
                    Text(profile.bio).font(.body).padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone: \(profile.phone ?? "N/A")")
                    let birthY = (profile.birthYear ?? "").isEmpty ? "N/A" : profile.birthYear!
                    Text("Birth Year: \(birthY)")
                    Text("Followers: \(profile.followers)")
                    Text("Friends: \(profile.friends)")
                    Text("Wins: \(profile.wins)")
                    Text("Losses: \(profile.losses)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
    }
}
