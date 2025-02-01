//
//  MatchModels.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Data models & enums for match scheduling (time, type) and “swipe” decisions.
//

import SwiftUI

// MARK: MatchTimeOption
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchTimeOption: String, CaseIterable {
    case now = "Now"
    case later = "Later"
}

// MARK: MatchTypeOption
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchTypeOption: String, CaseIterable {
    case oneAndDone = "One & Done"
    case best2of3   = "Best 2/3"
    case best3of5   = "Best 3/5"
}

// MARK: SwipeDecision
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum SwipeDecision: String, Codable {
    case yes
    case no
    case maybe
}

// MARK: CreatorMatchCandidate
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorMatchCandidate: Identifiable {
    public let id: String
    public let username: String
    public let bio: String
    public let location: String
    public let profilePictureURL: String
    
    public init(id: String,
                username: String,
                bio: String,
                location: String,
                profilePictureURL: String) {
        self.id = id
        self.username = username
        self.bio = bio
        self.location = location
        self.profilePictureURL = profilePictureURL
    }
}
