//
//  AdvancedBracketCreationView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: AdvancedBracketCreationView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A comprehensive bracket creation flow that supports editing all bracket details,
// adding real data for bracket participants, inviting creators, and selecting a predefined timezone.

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AdvancedBracketCreationView: View {
    public let title: String
    public let platform: LivePlatformOption
    
    @State private var bracketName = ""
    @State private var bracketCreator = ""
    @State private var startTime = Date()
    @State private var stopTime = Date().addingTimeInterval(3600)
    
    // Instead of typing a raw time zone, we select from a predefined list:
    @State private var bracketTimezone = "Pacific Time (PST/PDT) – UTC-8 or UTC-7 (DST)"
    
    private let bracketStyles = ["One and Done", "Best 2/3", "Best 3/5"]
    @State private var selectedBracketStyle = "One and Done"
    
    @State private var maxUsers: Int?
    
    @State private var showCSVImporter = false
    @State private var entries: [BracketEntry] = []
    @State private var showTimezonePicker = false
    
    public init(title: String, platform: LivePlatformOption) {
        self.title = title
        self.platform = platform
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bracket Info")) {
                    TextField("Bracket Name", text: $bracketName)
                    Text("Bracket Creator: \(bracketCreator.isEmpty ? "Loading..." : bracketCreator)")
                    Text("Associated Platform: \(platform.name)")
                    
                    DatePicker("Scheduled Start", selection: $startTime)
                    DatePicker("Scheduled Stop", selection: $stopTime)
                    
                    NavigationLink("Timezone: \(bracketTimezone)", destination: {
                        TimeZonePickerView(
                            currentSelection: $bracketTimezone
                        )
                    })
                    
                    Picker("Bracket Style", selection: $selectedBracketStyle) {
                        ForEach(bracketStyles, id: \.self) { style in
                            Text(style)
                        }
                    }
                    
                    Stepper(value: Binding(
                        get: { maxUsers ?? 0 },
                        set: { newVal in maxUsers = (newVal == 0 ? nil : newVal) }
                    ), in: 0...512) {
                        Text("Max Users: \(maxUsers.map(String.init) ?? "Unlimited")")
                    }
                }
                
                Section(header: Text("Participants")) {
                    Button("Add Entry Manually") { addManualEntry() }
                    Button("Import from CSV") { showCSVImporter = true }
                    
                    if entries.isEmpty {
                        Text("No participants yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(entries.indices, id: \.self) { idx in
                            NavigationLink(destination: EditBracketEntryView(entry: $entries[idx])) {
                                Text(entries[idx].username.isEmpty ? "Unnamed Participant" : entries[idx].username)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Create Bracket") { createBracket() }
                    Button("Share Bracket") { shareBracket() }
                }
            }
            .navigationTitle(title)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear { fetchBracketCreatorName() }
        .sheet(isPresented: $showCSVImporter) {
            CSVImporterView { importedEntries in
                entries.append(contentsOf: importedEntries)
            }
        }
    }
    
    private func fetchBracketCreatorName() {
        guard let uid = Auth.auth().currentUser?.uid else {
            bracketCreator = "Guest or Unknown"
            return
        }
        let db = FirebaseManager.shared.db
        db.collection("users").document(uid).getDocument { snap, err in
            if let err = err {
                print("Error fetching user profile: \(err.localizedDescription)")
                bracketCreator = "UnknownUser"
                return
            }
            guard let doc = snap, doc.exists else {
                bracketCreator = "UnknownUser"
                return
            }
            do {
                let userProfile = try doc.data(as: UserProfile.self)
                bracketCreator = userProfile.name
            } catch {
                print("Failed to decode user profile: \(error.localizedDescription)")
                bracketCreator = "UnknownUser"
            }
        }
    }
    
    private func addManualEntry() {
        let newEntry = BracketEntry(
            username: "",
            email: "",
            phone: "",
            platformUsername: "",
            discordUsername: "",
            daysOfWeekAvailable: [],
            timesAvailable: "",
            timezone: bracketTimezone,  // default to bracket’s selection
            networkOrAgency: nil,
            maxBracketMatches: 5,
            maxMatchesPerDay: 2,
            averageDiamondAmount: nil,
            preferredOpponents: [],
            excludedOpponents: [],
            additionalNotes: ""
        )
        entries.append(newEntry)
    }
    
    private func createBracket() {
        let bracketDoc: [String: Any] = [
            "title": title,
            "bracketName": bracketName,
            "bracketCreator": bracketCreator,
            "platform": platform.name,
            "startTime": startTime,
            "stopTime": stopTime,
            "timezone": bracketTimezone,
            "bracketStyle": selectedBracketStyle,
            "maxUsers": maxUsers as Any,
            "participants": entries.map { $0.toDictionary() }
        ]
        
        let db = FirebaseManager.shared.db
        db.collection("brackets").addDocument(data: bracketDoc) { err in
            if let err = err {
                print("Error creating bracket: \(err.localizedDescription)")
            } else {
                print("Bracket created successfully!")
            }
        }
    }
    
    private func shareBracket() {
        print("Sharing bracket with external apps… (placeholder)")
    }
}
