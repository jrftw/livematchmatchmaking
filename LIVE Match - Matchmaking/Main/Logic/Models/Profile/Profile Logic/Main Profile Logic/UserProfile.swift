//
//  UserProfile.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - UserProfile.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Data model for storing user data and syncing with Firestore.
// Includes custom Codable handling for non-codable fields like [Any].

import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct UserProfile: Identifiable, Codable {
    
    // MARK: - Firestore ID
    @DocumentID public var id: String?
    
    // MARK: - Core Profile Fields
    public var username: String
    public var bio: String
    public var phone: String?
    public var phonePublicly: Bool
    public var birthYear: String?
    public var birthYearPublicly: Bool
    public var email: String?
    public var emailPublicly: Bool
    public var clanTag: String?
    public var clanColorHex: String?
    public var profilePictureURL: String?
    public var bannerURL: String?
    
    // MARK: - Stats
    public var followers: Int
    public var friends: Int
    public var wins: Int
    public var losses: Int
    
    // MARK: - Collections
    public var livePlatforms: [String]
    public var livePlatformLinks: [String]
    public var agencies: [String]
    public var creatorNetworks: [String]
    public var teams: [String]
    public var communities: [String]
    public var tags: [String]
    public var socialLinks: [String]
    public var gamingAccounts: [String]
    public var gamingAccountDetails: [GamingAccountDetail]
    
    // Potentially non-codable:
    public var livePlatformDetails: [Any]
    
    // MARK: - Account Types & Related
    public var accountTypes: [AccountType]
    public var isSearching: Bool
    public var roster: [Any]?
    public var establishedDate: String?
    public var subscriptionActive: Bool
    public var subscriptionPrice: Double
    public var createdAt: Date
    public var hasCommunityMembership: Bool
    public var isCommunityAdmin: Bool
    public var hasGroupMembership: Bool
    public var isGroupAdmin: Bool
    public var hasTeamMembership: Bool
    public var isTeamAdmin: Bool
    public var hasAgencyMembership: Bool
    public var isAgencyAdmin: Bool
    public var hasCreatorNetworkMembership: Bool
    public var isCreatorNetworkAdmin: Bool
    
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case bio
        case phone
        case phonePublicly
        case birthYear
        case birthYearPublicly
        case email
        case emailPublicly
        case clanTag
        case clanColorHex
        case profilePictureURL
        case bannerURL
        case followers
        case friends
        case wins
        case losses
        case livePlatforms
        case livePlatformLinks
        case agencies
        case creatorNetworks
        case teams
        case communities
        case tags
        case socialLinks
        case gamingAccounts
        case gamingAccountDetails
        // exclude livePlatformDetails from coding
        case accountTypes
        case isSearching
        // exclude roster
        case establishedDate
        case subscriptionActive
        case subscriptionPrice
        case createdAt
        case hasCommunityMembership
        case isCommunityAdmin
        case hasGroupMembership
        case isGroupAdmin
        case hasTeamMembership
        case isTeamAdmin
        case hasAgencyMembership
        case isAgencyAdmin
        case hasCreatorNetworkMembership
        case isCreatorNetworkAdmin
    }
    
    // MARK: - Init
    public init(
        id: String? = nil,
        username: String = "",
        bio: String = "",
        phone: String? = nil,
        phonePublicly: Bool = false,
        birthYear: String? = nil,
        birthYearPublicly: Bool = false,
        email: String? = nil,
        emailPublicly: Bool = false,
        clanTag: String? = nil,
        clanColorHex: String? = nil,
        profilePictureURL: String? = nil,
        bannerURL: String? = nil,
        followers: Int = 0,
        friends: Int = 0,
        wins: Int = 0,
        losses: Int = 0,
        livePlatforms: [String] = [],
        livePlatformLinks: [String] = [],
        agencies: [String] = [],
        creatorNetworks: [String] = [],
        teams: [String] = [],
        communities: [String] = [],
        tags: [String] = [],
        socialLinks: [String] = [],
        gamingAccounts: [String] = [],
        gamingAccountDetails: [GamingAccountDetail] = [],
        livePlatformDetails: [Any] = [],
        accountTypes: [AccountType] = [],
        isSearching: Bool = false,
        roster: [Any]? = nil,
        establishedDate: String? = nil,
        subscriptionActive: Bool = false,
        subscriptionPrice: Double = 0.0,
        createdAt: Date = Date(),
        hasCommunityMembership: Bool = false,
        isCommunityAdmin: Bool = false,
        hasGroupMembership: Bool = false,
        isGroupAdmin: Bool = false,
        hasTeamMembership: Bool = false,
        isTeamAdmin: Bool = false,
        hasAgencyMembership: Bool = false,
        isAgencyAdmin: Bool = false,
        hasCreatorNetworkMembership: Bool = false,
        isCreatorNetworkAdmin: Bool = false
    ) {
        self.id = id
        self.username = username
        self.bio = bio
        self.phone = phone
        self.phonePublicly = phonePublicly
        self.birthYear = birthYear
        self.birthYearPublicly = birthYearPublicly
        self.email = email
        self.emailPublicly = emailPublicly
        self.clanTag = clanTag
        self.clanColorHex = clanColorHex
        self.profilePictureURL = profilePictureURL
        self.bannerURL = bannerURL
        self.followers = followers
        self.friends = friends
        self.wins = wins
        self.losses = losses
        self.livePlatforms = livePlatforms
        self.livePlatformLinks = livePlatformLinks
        self.agencies = agencies
        self.creatorNetworks = creatorNetworks
        self.teams = teams
        self.communities = communities
        self.tags = tags
        self.socialLinks = socialLinks
        self.gamingAccounts = gamingAccounts
        self.gamingAccountDetails = gamingAccountDetails
        self.livePlatformDetails = livePlatformDetails
        self.accountTypes = accountTypes
        self.isSearching = isSearching
        self.roster = roster
        self.establishedDate = establishedDate
        self.subscriptionActive = subscriptionActive
        self.subscriptionPrice = subscriptionPrice
        self.createdAt = createdAt
        self.hasCommunityMembership = hasCommunityMembership
        self.isCommunityAdmin = isCommunityAdmin
        self.hasGroupMembership = hasGroupMembership
        self.isGroupAdmin = isGroupAdmin
        self.hasTeamMembership = hasTeamMembership
        self.isTeamAdmin = isTeamAdmin
        self.hasAgencyMembership = hasAgencyMembership
        self.isAgencyAdmin = isAgencyAdmin
        self.hasCreatorNetworkMembership = hasCreatorNetworkMembership
        self.isCreatorNetworkAdmin = isCreatorNetworkAdmin
    }
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.phonePublicly = try container.decode(Bool.self, forKey: .phonePublicly)
        self.birthYear = try container.decodeIfPresent(String.self, forKey: .birthYear)
        self.birthYearPublicly = try container.decode(Bool.self, forKey: .birthYearPublicly)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.emailPublicly = try container.decode(Bool.self, forKey: .emailPublicly)
        self.clanTag = try container.decodeIfPresent(String.self, forKey: .clanTag)
        self.clanColorHex = try container.decodeIfPresent(String.self, forKey: .clanColorHex)
        self.profilePictureURL = try container.decodeIfPresent(String.self, forKey: .profilePictureURL)
        self.bannerURL = try container.decodeIfPresent(String.self, forKey: .bannerURL)
        self.followers = try container.decode(Int.self, forKey: .followers)
        self.friends = try container.decode(Int.self, forKey: .friends)
        self.wins = try container.decode(Int.self, forKey: .wins)
        self.losses = try container.decode(Int.self, forKey: .losses)
        self.livePlatforms = try container.decode([String].self, forKey: .livePlatforms)
        self.livePlatformLinks = try container.decode([String].self, forKey: .livePlatformLinks)
        self.agencies = try container.decode([String].self, forKey: .agencies)
        self.creatorNetworks = try container.decode([String].self, forKey: .creatorNetworks)
        self.teams = try container.decode([String].self, forKey: .teams)
        self.communities = try container.decode([String].self, forKey: .communities)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.socialLinks = try container.decode([String].self, forKey: .socialLinks)
        self.gamingAccounts = try container.decode([String].self, forKey: .gamingAccounts)
        self.gamingAccountDetails = try container.decode([GamingAccountDetail].self, forKey: .gamingAccountDetails)
        // omit livePlatformDetails
        self.livePlatformDetails = []
        
        self.accountTypes = try container.decode([AccountType].self, forKey: .accountTypes)
        self.isSearching = try container.decode(Bool.self, forKey: .isSearching)
        // omit roster
        self.roster = nil
        
        self.establishedDate = try container.decodeIfPresent(String.self, forKey: .establishedDate)
        self.subscriptionActive = try container.decode(Bool.self, forKey: .subscriptionActive)
        self.subscriptionPrice = try container.decode(Double.self, forKey: .subscriptionPrice)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.hasCommunityMembership = try container.decode(Bool.self, forKey: .hasCommunityMembership)
        self.isCommunityAdmin = try container.decode(Bool.self, forKey: .isCommunityAdmin)
        self.hasGroupMembership = try container.decode(Bool.self, forKey: .hasGroupMembership)
        self.isGroupAdmin = try container.decode(Bool.self, forKey: .isGroupAdmin)
        self.hasTeamMembership = try container.decode(Bool.self, forKey: .hasTeamMembership)
        self.isTeamAdmin = try container.decode(Bool.self, forKey: .isTeamAdmin)
        self.hasAgencyMembership = try container.decode(Bool.self, forKey: .hasAgencyMembership)
        self.isAgencyAdmin = try container.decode(Bool.self, forKey: .isAgencyAdmin)
        self.hasCreatorNetworkMembership = try container.decode(Bool.self, forKey: .hasCreatorNetworkMembership)
        self.isCreatorNetworkAdmin = try container.decode(Bool.self, forKey: .isCreatorNetworkAdmin)
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(bio, forKey: .bio)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encode(phonePublicly, forKey: .phonePublicly)
        try container.encodeIfPresent(birthYear, forKey: .birthYear)
        try container.encode(birthYearPublicly, forKey: .birthYearPublicly)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(emailPublicly, forKey: .emailPublicly)
        try container.encodeIfPresent(clanTag, forKey: .clanTag)
        try container.encodeIfPresent(clanColorHex, forKey: .clanColorHex)
        try container.encodeIfPresent(profilePictureURL, forKey: .profilePictureURL)
        try container.encodeIfPresent(bannerURL, forKey: .bannerURL)
        try container.encode(followers, forKey: .followers)
        try container.encode(friends, forKey: .friends)
        try container.encode(wins, forKey: .wins)
        try container.encode(losses, forKey: .losses)
        try container.encode(livePlatforms, forKey: .livePlatforms)
        try container.encode(livePlatformLinks, forKey: .livePlatformLinks)
        try container.encode(agencies, forKey: .agencies)
        try container.encode(creatorNetworks, forKey: .creatorNetworks)
        try container.encode(teams, forKey: .teams)
        try container.encode(communities, forKey: .communities)
        try container.encode(tags, forKey: .tags)
        try container.encode(socialLinks, forKey: .socialLinks)
        try container.encode(gamingAccounts, forKey: .gamingAccounts)
        try container.encode(gamingAccountDetails, forKey: .gamingAccountDetails)
        // omit livePlatformDetails
        try container.encode(accountTypes, forKey: .accountTypes)
        try container.encode(isSearching, forKey: .isSearching)
        // omit roster
        try container.encodeIfPresent(establishedDate, forKey: .establishedDate)
        try container.encode(subscriptionActive, forKey: .subscriptionActive)
        try container.encode(subscriptionPrice, forKey: .subscriptionPrice)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(hasCommunityMembership, forKey: .hasCommunityMembership)
        try container.encode(isCommunityAdmin, forKey: .isCommunityAdmin)
        try container.encode(hasGroupMembership, forKey: .hasGroupMembership)
        try container.encode(isGroupAdmin, forKey: .isGroupAdmin)
        try container.encode(hasTeamMembership, forKey: .hasTeamMembership)
        try container.encode(isTeamAdmin, forKey: .isTeamAdmin)
        try container.encode(hasAgencyMembership, forKey: .hasAgencyMembership)
        try container.encode(isAgencyAdmin, forKey: .isAgencyAdmin)
        try container.encode(hasCreatorNetworkMembership, forKey: .hasCreatorNetworkMembership)
        try container.encode(isCreatorNetworkAdmin, forKey: .isCreatorNetworkAdmin)
    }
}
