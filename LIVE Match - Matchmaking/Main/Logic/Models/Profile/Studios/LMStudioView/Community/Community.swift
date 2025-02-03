//
//  Community.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: Community.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// Represents a community doc in Firestore, storing name, mission, founder, etc.

import Firebase
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Community: Identifiable {
    public let id: String?
    public let name: String
    public let mission: String
    public let founderId: String
    public let foundedDate: Date
    public let profilePictureURL: String?
    public let bannerURL: String?
    
    public init(
        id: String?,
        name: String,
        mission: String,
        founderId: String,
        foundedDate: Date,
        profilePictureURL: String?,
        bannerURL: String?
    ) {
        self.id = id
        self.name = name
        self.mission = mission
        self.founderId = founderId
        self.foundedDate = foundedDate
        self.profilePictureURL = profilePictureURL
        self.bannerURL = bannerURL
    }
    
    public static func fromDict(documentId: String, dict: [String: Any]) -> Community {
        let name = dict["name"] as? String ?? "Unnamed"
        let mission = dict["mission"] as? String ?? ""
        let founderId = dict["founderId"] as? String ?? ""
        let ts = dict["foundedDate"] as? Timestamp
        let date = ts?.dateValue() ?? Date()
        let picURL = dict["profilePictureURL"] as? String
        let banURL = dict["bannerURL"] as? String
        
        return Community(
            id: documentId,
            name: name,
            mission: mission,
            founderId: founderId,
            foundedDate: date,
            profilePictureURL: picURL,
            bannerURL: banURL
        )
    }
    
    public func asDictionary() -> [String: Any] {
        [
            "name": name,
            "mission": mission,
            "founderId": founderId,
            "foundedDate": Timestamp(date: foundedDate),
            "profilePictureURL": profilePictureURL ?? "",
            "bannerURL": bannerURL ?? ""
        ]
    }
}