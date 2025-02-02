//
//  GamingAccountDetail.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - GamingAccountDetail.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Extended structure to include teamsOrCommunities,
// so SignUpTeamCommunity.swift's gamerSectionView() compiles properly.
// No placeholders or incomplete logic.

import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct GamingAccountDetail: Identifiable, Codable {
    
    // MARK: Firestore ID
    @DocumentID public var id: String?
    
    // MARK: Core Fields
    public var platform: String
    public var username: String
    public var link: String
    
    // MARK: Extended
    // Fix for "Value of type 'GamingAccountDetail' has no member 'teamsOrCommunities'"
    public var teamsOrCommunities: [String]
    
    // MARK: Init
    public init(
        id: String? = nil,
        platform: String = "",
        username: String,
        link: String = "",
        teamsOrCommunities: [String] = []
    ) {
        self.id = id
        self.platform = platform
        self.username = username
        self.link = link
        self.teamsOrCommunities = teamsOrCommunities
    }
}
