//
//  ProfileDetailView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays details of a given UserProfile.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
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
                    AsyncImage(url: URL(string: banner)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        case .failure(_):
                            Color.red.frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                if let pic = profile.profilePictureURL, !pic.isEmpty {
                    AsyncImage(url: URL(string: pic)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure(_):
                            Circle().fill(Color.gray)
                                .frame(width: 100, height: 100)
                        @unknown default:
                            EmptyView()
                        }
                    }
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
                
                // Additional details or lists here...
            }
            .padding()
        }
        .navigationTitle(profile.name.isEmpty ? "Profile" : profile.name)
    }
}
