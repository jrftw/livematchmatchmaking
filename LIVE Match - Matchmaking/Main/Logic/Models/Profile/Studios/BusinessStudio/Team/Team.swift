//
//  Team.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: Team.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// Represents a team doc with necessary fields: name, founding date, founders, contact info, banners, etc.

import Firebase
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Team: Identifiable {
    public let id: String?
    public let name: String
    public let username: String
    public let foundingDate: Date
    public let founders: String
    public let email: String
    public let phoneNumber: String
    public let website: String
    public let bannerURL: String?
    public let profilePictureURL: String?
    
    public init(
        id: String?,
        name: String,
        username: String,
        foundingDate: Date,
        founders: String,
        email: String,
        phoneNumber: String,
        website: String,
        bannerURL: String?,
        profilePictureURL: String?
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.foundingDate = foundingDate
        self.founders = founders
        self.email = email
        self.phoneNumber = phoneNumber
        self.website = website
        self.bannerURL = bannerURL
        self.profilePictureURL = profilePictureURL
    }
    
    public static func fromDict(_ dict: [String: Any], docID: String) -> Team {
        let name = dict["name"] as? String ?? "Untitled"
        let username = dict["username"] as? String ?? ""
        let ts = dict["foundingDate"] as? Timestamp
        let date = ts?.dateValue() ?? Date()
        let founders = dict["founders"] as? String ?? ""
        let email = dict["email"] as? String ?? ""
        let phone = dict["phoneNumber"] as? String ?? ""
        let site = dict["website"] as? String ?? ""
        let banner = dict["bannerURL"] as? String
        let pic = dict["profilePictureURL"] as? String
        
        return Team(
            id: docID,
            name: name,
            username: username,
            foundingDate: date,
            founders: founders,
            email: email,
            phoneNumber: phone,
            website: site,
            bannerURL: banner,
            profilePictureURL: pic
        )
    }
    
    public func asDictionary() -> [String: Any] {
        [
            "name": name,
            "username": username,
            "foundingDate": Timestamp(date: foundingDate),
            "founders": founders,
            "email": email,
            "phoneNumber": phoneNumber,
            "website": website,
            "bannerURL": bannerURL ?? "",
            "profilePictureURL": profilePictureURL ?? ""
        ]
    }
}