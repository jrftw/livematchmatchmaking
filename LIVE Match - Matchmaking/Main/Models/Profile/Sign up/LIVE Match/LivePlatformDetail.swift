//
//  LivePlatformDetail.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Defines LivePlatformDetail for referencing in user profiles.
//
import Foundation
import FirebaseFirestore

public struct LivePlatformDetail: Codable, Identifiable {
    @DocumentID public var id: String?
    public var username: String
    public var link: String
    public var agencyOrCreatorNetwork: String?
    public var teamsOrCommunities: [String]
    
    public init(
        id: String? = nil,
        username: String,
        link: String,
        agencyOrCreatorNetwork: String? = nil,
        teamsOrCommunities: [String]
    ) {
        self.id = id
        self.username = username
        self.link = link
        self.agencyOrCreatorNetwork = agencyOrCreatorNetwork
        self.teamsOrCommunities = teamsOrCommunities
    }
}
