//
//  CSVBracketEntry.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/6/25.
//


// MARK: CSVBracketEntry.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// The older “CSV” version with daysOfWeekAvailable, timesAvailable, etc.
// This does NOT conflict with BracketEntry because we renamed it.

import Foundation

public struct CSVBracketEntry: Identifiable {
    public let id = UUID()
    
    public var username: String
    public var email: String
    public var phone: String
    public var platformUsername: String
    public var discordUsername: String
    public var daysOfWeekAvailable: [String]
    public var timesAvailable: String
    public var timezone: String
    public var networkOrAgency: String?
    public var maxBracketMatches: Int
    public var maxMatchesPerDay: Int
    public var averageDiamondAmount: Int?
    public var preferredOpponents: [String]
    public var excludedOpponents: [String]
    public var additionalNotes: String
    
    public init(
        username: String,
        email: String,
        phone: String,
        platformUsername: String,
        discordUsername: String,
        daysOfWeekAvailable: [String],
        timesAvailable: String,
        timezone: String,
        networkOrAgency: String? = nil,
        maxBracketMatches: Int,
        maxMatchesPerDay: Int,
        averageDiamondAmount: Int? = nil,
        preferredOpponents: [String],
        excludedOpponents: [String],
        additionalNotes: String
    ) {
        self.username = username
        self.email = email
        self.phone = phone
        self.platformUsername = platformUsername
        self.discordUsername = discordUsername
        self.daysOfWeekAvailable = daysOfWeekAvailable
        self.timesAvailable = timesAvailable
        self.timezone = timezone
        self.networkOrAgency = networkOrAgency
        self.maxBracketMatches = maxBracketMatches
        self.maxMatchesPerDay = maxMatchesPerDay
        self.averageDiamondAmount = averageDiamondAmount
        self.preferredOpponents = preferredOpponents
        self.excludedOpponents = excludedOpponents
        self.additionalNotes = additionalNotes
    }
    
    // Convert CSVBracketEntry -> main BracketEntry 
    // e.g. store timesAvailable in timesByDay["Any Day"] as a single interval, 
    // or just keep it empty if you prefer. Adjust as needed.
    public func convertToBracketEntry() -> BracketEntry {
        // If you want to parse timesAvailable into TimeRange logic, do so.
        // Here we just put an empty dictionary for timesByDay 
        // and preserve the user’s chosen 'timezone'.
        
        return BracketEntry(
            // Provide some default ID or keep the random
            id: UUID(),
            username: username,
            email: email,
            phone: phone,
            platformUsername: platformUsername,
            discordUsername: discordUsername,
            timesByDay: [:], // or parse from timesAvailable if you like
            networkOrAgency: networkOrAgency,
            maxBracketMatches: maxBracketMatches,
            maxMatchesPerDay: maxMatchesPerDay,
            averageDiamondAmount: averageDiamondAmount,
            preferredOpponents: preferredOpponents,
            excludedOpponents: excludedOpponents,
            additionalNotes: additionalNotes
        )
    }
    
    // For Firestore or other usage 
    public func toDictionary() -> [String: Any] {
        [
            "username": username,
            "email": email,
            "phone": phone,
            "platformUsername": platformUsername,
            "discordUsername": discordUsername,
            "daysOfWeekAvailable": daysOfWeekAvailable,
            "timesAvailable": timesAvailable,
            "timezone": timezone,
            "networkOrAgency": networkOrAgency as Any,
            "maxBracketMatches": maxBracketMatches,
            "maxMatchesPerDay": maxMatchesPerDay,
            "averageDiamondAmount": averageDiamondAmount as Any,
            "preferredOpponents": preferredOpponents,
            "excludedOpponents": excludedOpponents,
            "additionalNotes": additionalNotes
        ]
    }
}