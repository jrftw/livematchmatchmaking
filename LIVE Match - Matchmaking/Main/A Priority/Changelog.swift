//
//  ChangelogView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays a list of changes by version/build.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChangelogView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(Changelog.entries) { entry in
                    Section(
                        header: Text("Version \(entry.version) (Build \(entry.build)) — Released \(entry.releaseDate)")
                    ) {
                        ForEach(entry.changes, id: \.self) { line in
                            Text("• \(line)")
                        }
                    }
                }
            }
            .navigationTitle("Changelog")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//
//  Changelog Model
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Contains the static entries displayed in ChangelogView.
//

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
    public static let entries: [ChangelogEntry] = [
        ChangelogEntry(
            version: "1.0",
            build: "1",
            releaseDate: "1/29/25",
            changes: [
                "Initial release of LIVE Match - Matchmaking.",
                "Introduced bracket creation flow and CSV import.",
                "Added user profiles with advanced editing.",
                "Implemented Feed with multiple filter toggles."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "2",
            releaseDate: "1/30/25",
            changes: [
                "Added Template CSV download for brackets.",
                "Improved bracket creation with predefined time zones.",
                "Fixed bottom bar navigation glitch (Menu icon now toggles properly).",
                "Introduced reorderable Main Menu layout (Edit Layout mode).",
                "Enabled Achievements page for non-guest users.",
                "Enhanced messaging with group chat, direct messages, and reactions.",
                "Improved synergy for macOS and visionOS, ensuring consistent UI.",
                "Implemented robust code reorganization for better performance and clarity."
            ]
        )
    ]
}
