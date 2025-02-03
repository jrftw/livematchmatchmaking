// MARK: - UserProfile.swift
// Universal user model for sign up, stored in Firestore

import SwiftUI
import FirebaseFirestore

public struct UserProfile: Codable, Identifiable {
    @DocumentID public var id: String?
    public var firstName: String
    public var lastName: String
    public var displayName: String
    public var username: String
    public var bio: String?
    
    public var birthday: String?
    public var birthdayPublicly: Bool
    
    public var email: String?
    public var emailPublicly: Bool
    
    public var phoneNumber: String?
    public var phonePublicly: Bool
    
    public var clanTag: String?
    public var clanColorHex: String?
    
    public var tags: [String]
    public var socialLinks: [String: String]
    
    public var profilePictureURL: String?
    public var bannerURL: String?
    
    public var createdAt: Date
    
    public init(
        id: String? = nil,
        firstName: String,
        lastName: String,
        displayName: String,
        username: String,
        bio: String? = nil,
        birthday: String? = nil,
        birthdayPublicly: Bool,
        email: String? = nil,
        emailPublicly: Bool,
        phoneNumber: String? = nil,
        phonePublicly: Bool,
        clanTag: String? = nil,
        clanColorHex: String? = nil,
        tags: [String],
        socialLinks: [String: String],
        profilePictureURL: String? = nil,
        bannerURL: String? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
        self.username = username
        self.bio = bio
        self.birthday = birthday
        self.birthdayPublicly = birthdayPublicly
        self.email = email
        self.emailPublicly = emailPublicly
        self.phoneNumber = phoneNumber
        self.phonePublicly = phonePublicly
        self.clanTag = clanTag
        self.clanColorHex = clanColorHex
        self.tags = tags
        self.socialLinks = socialLinks
        self.profilePictureURL = profilePictureURL
        self.bannerURL = bannerURL
        self.createdAt = createdAt
    }
}
