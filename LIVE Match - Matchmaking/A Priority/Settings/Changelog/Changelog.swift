//
//  Changelog.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Container holding all ChangelogEntry items.
//

import Foundation

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Changelog {
    // MARK: - Static Entries
    public static let entries: [ChangelogEntry] = [
        ChangelogEntry(
            version: "1.0",
            build: "1",
            releaseDate: "1/29/25",
            changes: [
                "First launch of LIVE Match - Matchmaking with basic bracket creation and CSV import.",
                "User profiles introduced, including advanced editing fields for personal info.",
                "Feed feature added, letting you filter posts by categories (Everyone, Friends, etc.)."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "2",
            releaseDate: "1/30/25",
            changes: [
                "Added a Template CSV download for easy bracket setup.",
                "Simplified bracket creation and time zone selection steps.",
                "Fixed a navigation bug where the bottom menu icon wouldn't toggle correctly.",
                "Added an Edit Layout mode so you can reorder the Main Menu buttons.",
                "Activated Achievements page for registered users, showing unlocked achievements.",
                "Improved group and direct messaging, plus new reactions for fun interactions.",
                "Better macOS and visionOS support for consistent layouts and styling.",
                "Cleaned up code to make everything more organized and faster."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "3",
            releaseDate: "2/1/25",
            changes: [
                "Enabled real-time push notifications so you never miss bracket updates.",
                "Updated Info.plist with location usage details to pass Apple checks.",
                "Added better background remote notifications for behind-the-scenes updates.",
                "Improved analytics and crash reporting for more stable tournament experiences.",
                "Polished match scheduling to handle time zone differences more gracefully.",
                "Unified UI across iOS, macOS, and visionOS for consistent design.",
                "Enhanced bracket error handling with clearer alerts."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "4",
            releaseDate: "2/2/25",
            changes: [
                "Launched a powerful bracket analytics dashboard, giving organizers real-time insights (match progress, participant stats, etc.).",
                "Upgraded time zone detection with a backup system that lets users manually choose if auto-detection fails.",
                "Improved notifications for matchmaking events, giving you faster alerts and more control over how you’re notified.",
                "Optimized the interface on older iPads and Apple Silicon Macs to reduce lag and improve animations.",
                "Tweaked visionOS layouts to ensure correct alignment for both 2D and mixed reality views.",
                "Enhanced bracket scheduling logs, making it easier to find and fix overlapping matches."
            ]
        ),
        ChangelogEntry(
            version: "1.0",
            build: "5",
            releaseDate: "2/3/25",
            changes: [
                "Rolled out a new matchmaking engine with smarter skill-based pairing to keep matches fair.",
                "Expanded bracket analytics with real-time stat overlays that show how your tournament is shaping up.",
                "Refreshed chat UI, so group and direct messages are easier to follow and respond to quickly.",
                "Upgraded server handling for scheduling and bracket updates to reduce wait times.",
                "Further optimized overall memory usage, ensuring smoother performance on all devices."
            ]
        )
    ]
}
