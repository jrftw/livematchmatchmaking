//
//  Changelog.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: Changelog.swift
// MARK: iOS 15.6+, macOS 11.5, visionOS 2.0+
// Stores a list of changes for each version, which can be displayed anywhere in the app.

import Foundation

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChangelogEntry: Identifiable {
    public let id = UUID()
    public let version: String
    public let build: String
    public let releaseDate: String
    public let changes: [String]
    
    public init(version: String, build: String, releaseDate: String, changes: [String]) {
        self.version = version
        self.build = build
        self.releaseDate = releaseDate
        self.changes = changes
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Changelog {
    // Example data. Expand as needed or fetch from a server.
    public static let entries: [ChangelogEntry] = [
        ChangelogEntry(
            version: "1.0",
            build: "1",
            releaseDate: "2025-01-28",
            changes: [
                "Initial release of LIVE Match - Matchmaking.",
                "Introduced bracket creation flow and CSV import.",
                "Added user profiles with advanced editing.",
                "Implemented Feed with multiple filter toggles."
            ]
        )
        // You can add more versions here as you release updates...
    ]
}
