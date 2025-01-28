//
//  CSVImporterView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  CSVImporterView+BracketEntry.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: CSVImporterView+BracketEntry.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// CSV importer and BracketEntry data model.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CSVImporterView: View {
    var onFinish: ([BracketEntry]) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CSV Importer")
            Button("Done") {
                let sample = [
                    BracketEntry(
                        username: "CSVUser1",
                        email: "csv1@mail.com",
                        phone: "555-1111",
                        platformUsername: "CSVUser1",
                        discordUsername: "CSVUser1#1111",
                        daysOfWeekAvailable: ["Wednesday"],
                        timesAvailable: "Afternoons",
                        timezone: TimeZone.current.identifier,
                        networkOrAgency: nil,
                        maxBracketMatches: 10,
                        maxMatchesPerDay: 3,
                        averageDiamondAmount: nil,
                        preferredOpponents: [],
                        excludedOpponents: [],
                        additionalNotes: "Imported from CSV"
                    )
                ]
                onFinish(sample)
            }
        }
        .padding()
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct BracketEntry: Identifiable {
    let id = UUID()
    
    var username: String
    var email: String
    var phone: String
    var platformUsername: String
    var discordUsername: String
    var daysOfWeekAvailable: [String]
    var timesAvailable: String
    var timezone: String
    var networkOrAgency: String?
    var maxBracketMatches: Int
    var maxMatchesPerDay: Int
    var averageDiamondAmount: Int?
    var preferredOpponents: [String]
    var excludedOpponents: [String]
    var additionalNotes: String
    
    func toDictionary() -> [String: Any] {
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