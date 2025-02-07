// MARK: AdvancedBracketCreationView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------
// Allows users to create an advanced bracket.
// After tapping "Create Bracket", we save to Firestore and dismiss the screen.

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
    
    @State private var bracketTimezone = "Pacific Time (PST/PDT) – UTC-8 or UTC-7 (DST)"
    private let bracketStyles = ["One and Done", "Best 2/3", "Best 3/5"]
    @State private var selectedBracketStyle = "One and Done"
    
    @State private var maxUsers: Int?
    
    @State private var showCSVImporter = false
    
    // The final array of *real* BracketEntry objects
    @State private var entries: [BracketEntry] = []
    
    @State private var showTimezonePicker = false
    
    // MARK: - Dismiss
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    NavigationLink("Timezone: \(bracketTimezone)") {
                        TimeZonePickerView(currentSelection: $bracketTimezone)
                    }
                    
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
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .onAppear { fetchBracketCreatorName() }
        .sheet(isPresented: $showCSVImporter) {
            // CSVImporterView now returns [CSVBracketEntry], so we convert each to BracketEntry
            CSVImporterView { importedCSVEntries in
                let converted = importedCSVEntries.map { $0.convertToBracketEntry() }
                entries.append(contentsOf: converted)
            }
        }
    }
    
    // MARK: - Load Bracket Creator
    private func fetchBracketCreatorName() {
        guard let uid = Auth.auth().currentUser?.uid else {
            bracketCreator = "Guest or Unknown"
            return
        }
        let db = FirebaseManager.shared.db
        
        db.collection("users").document(uid).getDocument { docSnap, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                bracketCreator = "UnknownUser"
                return
            }
            guard let docSnap = docSnap, docSnap.exists else {
                bracketCreator = "UnknownUser"
                return
            }
            
            do {
                let userProfile = try docSnap.data(as: UserProfile.self)
                bracketCreator = userProfile.username
            } catch {
                print("Failed to decode user profile: \(error.localizedDescription)")
                bracketCreator = "UnknownUser"
            }
        }
    }
    
    // MARK: - Add Entry Manually
    private func addManualEntry() {
        // timesByDay is empty dictionary by default
        let newEntry = BracketEntry(
            username: "",
            email: "",
            phone: "",
            platformUsername: "",
            discordUsername: "",
            timesByDay: [:],
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
    
    // MARK: - Create Bracket
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
                // Dismiss the screen after successful creation
                dismiss()
            }
        }
    }
    
    // MARK: - Share Bracket
    private func shareBracket() {
        print("Sharing bracket with external apps… (placeholder)")
    }
}

extension BracketEntry {
    // Provide a dictionary for Firestore or others
    func toDictionary() -> [String: Any] {
        // timesByDay is a dictionary of [String : [TimeRange]]
        // If you want to encode [TimeRange] as JSON, do so.
        // Example approach (very simple) – you might prefer custom logic:
        
        let timesByDayJSON = timesByDay.mapValues { ranges in
            ranges.map { range -> [String: Any] in
                [
                    "id": range.id.uuidString,
                    "start": range.start,
                    "end": range.end
                ]
            }
        }
        
        return [
            "id": id.uuidString,
            "username": username,
            "email": email,
            "phone": phone,
            "platformUsername": platformUsername,
            "discordUsername": discordUsername,
            "timesByDay": timesByDayJSON,
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
