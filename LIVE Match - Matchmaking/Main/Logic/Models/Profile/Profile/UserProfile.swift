//
//  UserProfile.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  The core data model for each user, including their username.
//

import SwiftUI
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

public struct GamingAccountDetail: Codable, Identifiable {
    public var id: String?
    public var username: String
    public var teamsOrCommunities: [String]
    
    public init(id: String? = nil,
                username: String,
                teamsOrCommunities: [String]) {
        self.id = id
        self.username = username
        self.teamsOrCommunities = teamsOrCommunities
    }
}

public struct LivePlatformDetail: Codable, Identifiable {
    public var id: String?
    public var username: String
    public var link: String
    public var agencyOrCreatorNetwork: String?
    public var teamsOrCommunities: [String]
    
    public init(id: String? = nil,
                username: String,
                link: String,
                agencyOrCreatorNetwork: String? = nil,
                teamsOrCommunities: [String]) {
        self.id = id
        self.username = username
        self.link = link
        self.agencyOrCreatorNetwork = agencyOrCreatorNetwork
        self.teamsOrCommunities = teamsOrCommunities
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct UserProfile: Codable, Identifiable {
    @DocumentID public var id: String?
    
    public var username: String
    public var accountTypes: [AccountType]
    public var email: String?
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
    
    public init(
        id: String? = nil,
        username: String,
        accountTypes: [AccountType],
        email: String? = nil,
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
        createdAt: Date,
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
        self.accountTypes = accountTypes
        self.email = email
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
}
