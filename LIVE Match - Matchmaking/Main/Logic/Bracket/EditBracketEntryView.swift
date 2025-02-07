// MARK: EditBracketEntryView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows editing real data in a BracketEntry. For each day of the week,
// the user can add multiple available time intervals instead of a single text field.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct EditBracketEntryView: View {
    @Binding var entry: BracketEntry
    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Username", text: $entry.username)
                TextField("Email", text: $entry.email)
                TextField("Phone", text: $entry.phone)
                TextField("Platform Username", text: $entry.platformUsername)
                TextField("Discord Username", text: $entry.discordUsername)
            }
            
            // MARK: - Multi-Day / Time Intervals
            Section(header: Text("Availability (Multiple Times Per Day)")) {
                TimesByDayAvailabilityView(timesByDay: $entry.timesByDay)
            }
            
            Section(header: Text("Network/Agency")) {
                TextField(
                    "Network or Agency",
                    text: Binding(
                        get: { entry.networkOrAgency ?? "" },
                        set: { entry.networkOrAgency = $0.isEmpty ? nil : $0 }
                    )
                )
            }
            
            Section(header: Text("Limits")) {
                Stepper(
                    "Max Bracket Matches: \(entry.maxBracketMatches)",
                    value: $entry.maxBracketMatches,
                    in: 1...100
                )
                Stepper(
                    "Max Matches per Day: \(entry.maxMatchesPerDay)",
                    value: $entry.maxMatchesPerDay,
                    in: 1...24
                )
            }
            
            Section(header: Text("Optional Diamonds")) {
                TextField("Average Diamond Amount",
                          value: $entry.averageDiamondAmount,
                          format: .number)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("Preferred Opponents")) {
                OpponentListView(opponents: $entry.preferredOpponents, label: "Add Opponent")
            }
            
            Section(header: Text("Excluded Opponents")) {
                OpponentListView(opponents: $entry.excludedOpponents, label: "Add Exclusion")
            }
            
            Section(header: Text("Additional Notes")) {
                if #available(iOS 16.0, *) {
                    TextField("", text: $entry.additionalNotes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                } else {
                    TextEditor(text: $entry.additionalNotes)
                        .frame(height: 80)
                }
            }
        }
        .navigationTitle("Edit Participant")
    }
}
