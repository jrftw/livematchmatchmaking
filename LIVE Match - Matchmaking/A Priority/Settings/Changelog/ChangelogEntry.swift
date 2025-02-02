//
//  ChangelogEntry.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Model for a single changelog entry.

import Foundation

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChangelogEntry: Identifiable {
    // MARK: - Properties
    public let id = UUID()
    public let version: String
    public let build: String
    public let releaseDate: String
    public let changes: [String]
    
    // MARK: - Init
    public init(version: String, build: String, releaseDate: String, changes: [String]) {
        print("[ChangelogEntry] init => version: \(version), build: \(build), releaseDate: \(releaseDate)")
        self.version = version
        self.build = build
        self.releaseDate = releaseDate
        self.changes = changes
        print("[ChangelogEntry] init completed.")
    }
}
