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
        // MARK: Build 9
        ChangelogEntry(
            version: "1.0",
            build: "9",
            releaseDate: "2/6/25",
            changes: [
                "Deployed a new tournament scoreboard that updates in real-time across all connected devices.",
                "Refined availability scheduling, making it simpler to view and edit multi-day brackets.",
                "Enhanced bracket cancellation logic to handle last-minute player dropouts gracefully.",
                "Added new advanced analytics for community managers, tracking average match durations, peak concurrency, and user retention metrics.",
                "Fixed several UI alignment issues on iPhone SE and iPhone Mini devices, improving readability in smaller form factors."
            ]
        )
    ]
}
