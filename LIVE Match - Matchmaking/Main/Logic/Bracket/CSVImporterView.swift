//
//  CSVImporterView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: CSVImporterView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows users to import a CSV of bracket entries, with an option to download a template.

import SwiftUI

// MARK: BracketEntry Definition (if not defined elsewhere)
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BracketEntry: Identifiable {
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
        networkOrAgency: String?,
        maxBracketMatches: Int,
        maxMatchesPerDay: Int,
        averageDiamondAmount: Int?,
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

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CSVImporterView: View {
    var onFinish: ([BracketEntry]) -> Void
    @State private var showTemplate = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CSV Importer")
                .font(.title2)
            
            Button("Download Template CSV") {
                showTemplate = true
            }
            
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
                        timezone: "Pacific Time (PST/PDT) – UTC-8 or UTC-7 (DST)",
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
        .sheet(isPresented: $showTemplate) {
            CSVTemplateDownloadWrapper()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CSVTemplateDownloadWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showShare = false
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            CSVTemplateDownloadView()
                .navigationTitle("CSV Template")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .onChange(of: showShare) { _ in
                    // no-op
                }
        }
    }
}
