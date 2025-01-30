// MARK: UserProfileModels.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Contains AccountType enum and UserProfile struct.

import Foundation
import FirebaseFirestore

public enum AccountType: String, Codable, CaseIterable, Hashable {
    case guest
    case viewer
    case creator
    case gamer
    case team
    case agency
    case creatornetwork
    case scouter
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
    
    public var tags: [String]
    public var socialLinks: [String]
    public var gamingAccounts: [String]
    public var livePlatforms: [String]
    
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
    
    public init(
        id: String? = nil,
        accountTypes: [AccountType],
        email: String? = nil,
        name: String,
        bio: String,
        birthYear: String? = nil,
        phone: String? = nil,
        profilePictureURL: String? = nil,
        bannerURL: String? = nil,
        clanTag: String? = nil,
        tags: [String],
        socialLinks: [String],
        gamingAccounts: [String],
        livePlatforms: [String],
        gamingAccountDetails: [GamingAccountDetail],
        livePlatformDetails: [LivePlatformDetail],
        followers: Int,
        friends: Int,
        isSearching: Bool,
        wins: Int,
        losses: Int,
        roster: [String],
        establishedDate: String? = nil,
        subscriptionActive: Bool,
        subscriptionPrice: Double,
        createdAt: Date
    ) {
        self.id = id
        self.accountTypes = accountTypes
        self.email = email
        self.name = name
        self.bio = bio
        self.birthYear = birthYear
        self.phone = phone
        self.profilePictureURL = profilePictureURL
        self.bannerURL = bannerURL
        self.clanTag = clanTag
        self.tags = tags
        self.socialLinks = socialLinks
        self.gamingAccounts = gamingAccounts
        self.livePlatforms = livePlatforms
        self.gamingAccountDetails = gamingAccountDetails
        self.livePlatformDetails = livePlatformDetails
        self.followers = followers
        self.friends = friends
        self.isSearching = isSearching
        self.wins = wins
        self.losses = losses
        self.roster = roster
        self.establishedDate = establishedDate
        self.subscriptionActive = subscriptionActive
        self.subscriptionPrice = subscriptionPrice
        self.createdAt = createdAt
    }
}
