//
//  MyUserProfile.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  An alternate user profile model, now with `hasRemoveAds`.
//

import SwiftUI
import FirebaseFirestore

public struct MyUserProfile: Codable, Identifiable {
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
    
    /// Indicates if the user has subscribed to "Remove Ads."
    public var hasRemoveAds: Bool
    
    // MARK: - Init
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
        createdAt: Date,
        hasCommunityMembership: Bool,
        isCommunityAdmin: Bool,
        hasGroupMembership: Bool,
        isGroupAdmin: Bool,
        hasTeamMembership: Bool,
        isTeamAdmin: Bool,
        hasAgencyMembership: Bool,
        isAgencyAdmin: Bool,
        hasCreatorNetworkMembership: Bool,
        isCreatorNetworkAdmin: Bool,
        hasRemoveAds: Bool = false  // <--- ADDED, defaults to false
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
        
        // New field for "Remove Ads"
        self.hasRemoveAds = hasRemoveAds
    }
}
