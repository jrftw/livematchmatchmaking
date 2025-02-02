//
//  AccountType.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - AccountType.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Enumeration of available account types, extended to include
// gamer, team, agency, etc. based on references throughout the project.

import SwiftUI
import FirebaseFirestore

public enum AccountType: String, Codable {
    case guest
    case Solo
    case Community
    case Business
    case standard
    case premium
    case viewer
    case creator
    case gamer
    case team
    case agency
    case creatornetwork
    case scouter
}
