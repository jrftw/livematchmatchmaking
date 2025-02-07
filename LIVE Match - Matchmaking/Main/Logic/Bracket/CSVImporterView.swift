// MARK: CSVImporterView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// Allows users to import a CSV of bracket entries,
// returning [CSVBracketEntry] (no duplicates with main BracketEntry).

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CSVImporterView: View {
    // We return CSVBracketEntry, not BracketEntry
    var onFinish: ([CSVBracketEntry]) -> Void
    @State private var showTemplate = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CSV Importer")
                .font(.title2)
            
            Button("Download Template CSV") {
                showTemplate = true
            }
            
            Button("Done") {
                // Example usage: one sample CSVBracketEntry
                let sample = [
                    CSVBracketEntry(
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
        }
    }
}
