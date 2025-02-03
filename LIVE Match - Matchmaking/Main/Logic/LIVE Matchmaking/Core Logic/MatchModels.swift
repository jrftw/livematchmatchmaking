// MARK: MatchModels.swift

//
//  MatchModels.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchTimeOption: String, CaseIterable {
    case now = "Now"
    case later = "Later"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchTypeOption: String, CaseIterable {
    case oneAndDone = "One & Done"
    case bestOfThree = "Best of 3"
    case marathon = "Marathon"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum SwipeDecision: String, Codable {
    case yes
    case no
    case maybe
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorMatchCandidate: Identifiable, Codable {
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
