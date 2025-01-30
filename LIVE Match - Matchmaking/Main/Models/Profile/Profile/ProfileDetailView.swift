//
//  ProfileDetailView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


//
//  ProfileDetailView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
import SwiftUI

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