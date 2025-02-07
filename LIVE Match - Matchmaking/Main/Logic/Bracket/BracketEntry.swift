// MARK: BracketEntry.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// The main bracket entry used by AdvancedBracketCreationView & EditBracketEntryView.

import Foundation

public struct BracketEntry: Identifiable, Codable {
    public var id: UUID
    public var username: String
    public var email: String
    public var phone: String
    public var platformUsername: String
    public var discordUsername: String
    
    // This references the now public TimeRange
    public var timesByDay: [String: [TimeRange]]
    
    public var networkOrAgency: String?
    public var maxBracketMatches: Int
    public var maxMatchesPerDay: Int
    public var averageDiamondAmount: Int?
    
    public var preferredOpponents: [String]
    public var excludedOpponents: [String]
    public var additionalNotes: String
    
    // Provide explicit coding keys if needed. If not, rely on Swift's defaults:
    // enum CodingKeys: ... { ... }
    
    public init(
        id: UUID = UUID(),
        username: String,
        email: String,
        phone: String,
        platformUsername: String,
        discordUsername: String,
        timesByDay: [String: [TimeRange]] = [:],
        networkOrAgency: String? = nil,
        maxBracketMatches: Int = 5,
        maxMatchesPerDay: Int = 2,
        averageDiamondAmount: Int? = nil,
        preferredOpponents: [String] = [],
        excludedOpponents: [String] = [],
        additionalNotes: String = ""
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.phone = phone
        self.platformUsername = platformUsername
        self.discordUsername = discordUsername
        self.timesByDay = timesByDay
        self.networkOrAgency = networkOrAgency
        self.maxBracketMatches = maxBracketMatches
        self.maxMatchesPerDay = maxMatchesPerDay
        self.averageDiamondAmount = averageDiamondAmount
        self.preferredOpponents = preferredOpponents
        self.excludedOpponents = excludedOpponents
        self.additionalNotes = additionalNotes
    }
}
