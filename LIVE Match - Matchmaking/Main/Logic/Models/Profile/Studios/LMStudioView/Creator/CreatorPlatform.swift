//
//  CreatorPlatform.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: CreatorPlatform.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Data model for each platform in the Creator studio.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorPlatform: Codable {
    public var name: String
    public var enabled: Bool = false
    public var username: String = ""
    public var profileLink: String = ""
    public var inAgency: Bool = false
    public var agencyName: String = ""
    
    public init(
        name: String,
        enabled: Bool = false,
        username: String = "",
        profileLink: String = "",
        inAgency: Bool = false,
        agencyName: String = ""
    ) {
        self.name = name
        self.enabled = enabled
        self.username = username
        self.profileLink = profileLink
        self.inAgency = inAgency
        self.agencyName = agencyName
    }
    
    public func asDictionary() -> [String: Any] {
        [
            "name": name,
            "enabled": enabled,
            "username": username,
            "profileLink": profileLink,
            "inAgency": inAgency,
            "agencyName": agencyName
        ]
    }
}