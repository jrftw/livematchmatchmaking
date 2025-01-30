//
//  GamingAccountDetail.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Defines GamingAccountDetail for referencing in user profiles.
//
import Foundation
import FirebaseFirestore

public struct GamingAccountDetail: Codable, Identifiable {
    @DocumentID public var id: String?
    public var username: String
    public var teamsOrCommunities: [String]
    
    public init(
        id: String? = nil,
        username: String,
        teamsOrCommunities: [String]
    ) {
        self.id = id
        self.username = username
        self.teamsOrCommunities = teamsOrCommunities
    }
}
