// MARK: Changelog.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Stores a static list of ChangelogEntry items to display version history.
// Now sorted so the newest entry is at the top and oldest at the bottom.

import Foundation

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Changelog {
    public static let entries: [ChangelogEntry] = [
        // MARK: Version 1.03 Build 1
        ChangelogEntry(
            version: "1.03",
            build: "1",
            releaseDate: "2/8/25",
            changes: [
                "Improved stability and responsiveness during heavy bracket updates.",
                "Fixed minor bugs reported in version 1.02 regarding user sign-up flow and UI glitches."
            ]
        ),
        // MARK: Version 1.02 Build 1
        ChangelogEntry(
            version: "1.02",
            build: "1",
            releaseDate: "2/7/25",
            changes: [
                "Introduced new advanced bracket filtering options, letting organizers refine participant pools by skill or region.",
                "Fixed an issue where signing up would not process correctly.",
                "Extended cross-platform chat presence detection (now updates your status across iOS, macOS, and visionOS in near real time).",
                "Fixed minor UI alignment issues on certain iPad split-screen configurations.",
                "Further polished memory usage, ensuring stable performance even during heavy bracket updates."
            ]
        ),
        // MARK: Version 1.01 Build 1
        ChangelogEntry(
            version: "1.01",
            build: "1",
            releaseDate: "2/6/25",
            changes: [
                "Initial release for 1.01. Released and advertising to the public."
            ]
        ),
        // MARK: Build 8
        ChangelogEntry(
            version: "1.0",
            build: "8",
            releaseDate: "2/5/25",
            changes: [
                "Upgraded matchmaking logic with new skill tiers for more accurate pairing.",
                "Overhauled the bracket scheduling engine to support custom date/time formats in different locales.",
                "Introduced a 'Search' feature (currently disabled by default) in the bottom bar for upcoming expansions.",
                "Improved overall stability, reducing random logout occurrences for certain iCloud-based sign-ins.",
                "Expanded daily login tracking with a dedicated user progress log in the background, capturing more session data for analytics."
            ]
        ),
        // MARK: Build 7
        ChangelogEntry(
            version: "1.0",
            build: "7",
            releaseDate: "2/4/25",
            changes: [
                "Enhanced Achievements system to award daily login only once per day.",
                "Refined Leaderboards integration to reflect totalScore and loginStreak in real time.",
                "Improved the reporting/blocking feature with better success feedback and error handling.",
                "Optimized feed filtering, adding a toggle for objectionable content (placeholder for future moderation tools).",
                "Fixed minor UI glitches in macOS and visionOS layouts, especially in sidebars and navigation bars."
            ]
        ),
        // MARK: Build 6
        ChangelogEntry(
            version: "1.0",
            build: "6",
            releaseDate: "2/4/25",
            changes: [
                "Introduced personalized match reminders, letting players opt in to receive push notifications when a match or bracket is about to begin.",
                "Improved bracket analytics to show participant progress graphs in real time.",
                "Refined the in-app messaging design with more responsive group chat layouts and new emoji support.",
                "Revamped location services to accurately detect user time zones without requiring continuous background access.",
                "Added offline mode for bracket browsing, allowing participants to view schedules and statuses even without a network connection."
            ]
        ),
        // MARK: Build 5
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
        ),
        // MARK: Build 4
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
        // MARK: Build 3
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
        // MARK: Build 2
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
        // MARK: Build 1
        ChangelogEntry(
            version: "1.0",
            build: "1",
            releaseDate: "1/29/25",
            changes: [
                "First launch of LIVE Match - Matchmaking with basic bracket creation and CSV import.",
                "User profiles introduced, including advanced editing fields for personal info.",
                "Feed feature added, letting you filter posts by categories (Everyone, Friends, etc.)."
            ]
        )
    ]
}
