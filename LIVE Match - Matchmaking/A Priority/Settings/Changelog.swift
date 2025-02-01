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
                "Enhanced bracket creation wizard with a streamlined UI.",
                "Fixed bottom bar navigation glitch (Menu icon now toggles properly).",
                "Introduced reorderable Main Menu layout (Edit Layout mode).",
                "Enabled Achievements page for non-guest users.",
                "Enhanced messaging with group chat, direct messages, and reactions.",
                "Improved synergy for macOS and visionOS, ensuring consistent UI.",
                "Implemented robust code reorganization for better performance and clarity.",
                "Various bug fixes and UI refinements to improve stability."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "3",
            releaseDate: "2/1/25",
            changes: [
                "Enabled in-app push notifications for real-time updates.",
                "Refined Info.plist with correct usage descriptions for location tracking.",
                "Resolved Apple validation issue regarding missing NSLocationWhenInUseUsageDescription.",
                "Increased build number to 3 and improved background remote notification handling.",
                "Implemented additional analytics events and crash reporting for better insights.",
                "Enhanced reliability of match scheduling logic with improved date/time zone handling.",
                "Unified UI design for iOS, macOS, and visionOS with optimized layout scaling.",
                "Strengthened error handling and logging in bracket features.",
                "General performance improvements and code refactoring for future expansions."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "4",
            releaseDate: "2/2/25",
            changes: [
                "Introduced advanced bracket analytics dashboard for organizers.",
                "Refined location-based time zone detection with fallback logic.",
                "Enhanced Discord integration for community engagement.",
                "Improved push notifications for user matchmaking events and updates.",
                "Optimized UI performance on older iPads and Apple Silicon Macs.",
                "Resolved minor layout issues on visionOS headsets.",
                "Extended logging for troubleshooting bracket scheduling conflicts."
            ]
        )
    ]
}
