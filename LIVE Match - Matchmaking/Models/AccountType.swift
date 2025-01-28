// MARK: File 1: Models.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Includes new substructures for GamingAccountDetail, LivePlatformDetail, plus optional "tags."

import Foundation
import FirebaseFirestore

public enum AccountType: String, Codable, CaseIterable, Hashable {
    case guest
    case creator
    case gamer
    case team
    case agency
    case creatornetwork
    case scouter
}

public struct GamingAccountDetail: Codable, Identifiable {
    @DocumentID public var id: String?
    public var username: String
    public var teamsOrCommunities: [String]
}

public struct LivePlatformDetail: Codable, Identifiable {
    @DocumentID public var id: String?
    public var username: String
    public var link: String
    public var agencyOrCreatorNetwork: String?
    public var teamsOrCommunities: [String]
}

public struct UserProfile: Codable, Identifiable {
    @DocumentID public var id: String?
    
    public var accountTypes: [AccountType]
    
    public var email: String?
    public var name: String
    public var bio: String
    public var birthYear: String?
    public var phone: String?
    
    public var profilePictureURL: String?
    public var bannerURL: String?
    public var clanTag: String?
    
    public var tags: [String]                // e.g., "LIVEMatch", "Battle Creator", etc.
    public var socialLinks: [String]         // older approach
    public var gamingAccounts: [String]      // older approach
    public var livePlatforms: [String]       // older approach
    
    public var gamingAccountDetails: [GamingAccountDetail]
    public var livePlatformDetails: [LivePlatformDetail]
    
    public var followers: Int
    public var friends: Int
    public var isSearching: Bool
    public var wins: Int
    public var losses: Int
    
    public var roster: [String]
    public var establishedDate: String?
    
    public var subscriptionActive: Bool
    public var subscriptionPrice: Double
    
    public var createdAt: Date
}

// MARK: FeedPost
public struct FeedPost: Codable, Identifiable {
    @DocumentID public var id: String?
    public var authorID: String
    public var text: String
    public var mediaURL: String?
    public var timestamp: Date
}

public struct TournamentMatch: Codable, Identifiable {
    @DocumentID public var id: String?
    public var player1ID: String
    public var player2ID: String
    public var winnerID: String?
    public var isComplete: Bool
}

public struct Event: Codable, Identifiable {
    @DocumentID public var id: String?
    public var title: String
    public var date: Date
    public var participants: [String]
    public var description: String
}

public struct Tournament: Codable, Identifiable {
    @DocumentID public var id: String?
    public var title: String
    public var description: String
    public var participants: [String]
    public var matches: [TournamentMatch]
    public var events: [Event]
}

public struct ChatMessage: Codable, Identifiable {
    @DocumentID public var id: String?
    public var text: String
    public var sender: String
    public var timestamp: Date
}

public struct DirectMessage: Codable, Identifiable {
    @DocumentID public var id: String?
    public var fromUserID: String
    public var toUserID: String
    public var text: String
    public var timestamp: Date
}
