// FILE: FillInBracketSlotEditView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------
// A subview for editing one bracket slot's details. The user can pick from known creators/agencies
// or type manually. Times are displayed in multiple timezones for convenience.

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketSlotEditView: View {
    // MARK: - State & Props
    @State var slot: FillInBracketSlot
    var onSave: ((FillInBracketSlot) -> Void)?
    var onCancel: (() -> Void)?
    
    // MARK: - Dynamic Known Lists
    @State private var knownCreators: [String] = []
    @State private var knownAgencies: [String] = []
    
    // MARK: - Init
    public init(
        slot: FillInBracketSlot,
        onSave: ((FillInBracketSlot) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._slot = State(initialValue: slot)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date & Time")) {
                    DatePicker("Select Date/Time",
                               selection: $slot.startDateTime,
                               displayedComponents: [.date, .hourAndMinute])
                    timeZoneDisplayRows(for: slot.startDateTime)
                }
                
                Section(header: Text("Creator #1")) {
                    Picker("Select from known creators", selection: $slot.creator1) {
                        Text("Manual Entry").tag("")
                        ForEach(knownCreators, id: \.self) { creatorName in
                            Text(creatorName).tag(creatorName)
                        }
                    }
                    TextField("Or manually type a name", text: $slot.creator1)
                    
                    Picker("Network/Agency", selection: $slot.creatorNetworkOrAgency1) {
                        Text("None / Manual Entry").tag("")
                        ForEach(knownAgencies, id: \.self) { agencyName in
                            Text(agencyName).tag(agencyName)
                        }
                    }
                    TextField("Or manually type (Optional)", text: $slot.creatorNetworkOrAgency1)
                    
                    TextField("Category", text: $slot.category1)
                    TextField("Diamond Avg", text: $slot.diamondAvg1)
                    
                    Toggle("Creator #1 Confirmed?", isOn: $slot.creator1Confirmed)
                }
                
                Section(header: Text("Creator #2")) {
                    Picker("Select from known creators", selection: $slot.creator2) {
                        Text("Manual Entry").tag("")
                        ForEach(knownCreators, id: \.self) { creatorName in
                            Text(creatorName).tag(creatorName)
                        }
                    }
                    TextField("Or manually type a name", text: $slot.creator2)
                    
                    Picker("Network/Agency", selection: $slot.creatorNetworkOrAgency2) {
                        Text("None / Manual Entry").tag("")
                        ForEach(knownAgencies, id: \.self) { agencyName in
                            Text(agencyName).tag(agencyName)
                        }
                    }
                    TextField("Or manually type (Optional)", text: $slot.creatorNetworkOrAgency2)
                    
                    TextField("Category", text: $slot.category2)
                    TextField("Diamond Avg", text: $slot.diamondAvg2)
                    
                    Toggle("Creator #2 Confirmed?", isOn: $slot.creator2Confirmed)
                }
                
                Section(header: Text("Status / Notes")) {
                    Picker("Status", selection: $slot.status) {
                        ForEach(MatchStatus.allCases, id: \.self) { st in
                            Text(st.rawValue)
                        }
                    }
                    TextField("Notes", text: $slot.notes)
                    TextField("Link", text: $slot.link)
                }
            }
            .navigationTitle("Edit Slot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave?(slot)
                    }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
        .onAppear {
            loadKnownCreators()
            loadKnownAgencies()
        }
    }
    
    // MARK: - Load Known Creators
    private func loadKnownCreators() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading known creators: \(error.localizedDescription)")
                return
            }
            guard let docs = snapshot?.documents else { return }
            var fetched: [String] = []
            for doc in docs {
                let username = doc.data()["username"] as? String ?? ""
                if !username.isEmpty {
                    fetched.append(username)
                }
            }
            DispatchQueue.main.async {
                self.knownCreators = fetched
            }
        }
    }
    
    // MARK: - Load Known Agencies
    private func loadKnownAgencies() {
        let db = Firestore.firestore()
        db.collection("agencies").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading known agencies: \(error.localizedDescription)")
                return
            }
            guard let docs = snapshot?.documents else { return }
            var fetched: [String] = []
            for doc in docs {
                let agencyName = doc.data()["name"] as? String ?? ""
                if !agencyName.isEmpty {
                    fetched.append(agencyName)
                }
            }
            DispatchQueue.main.async {
                self.knownAgencies = fetched
            }
        }
    }
    
    // MARK: - TimeZone Display
    @ViewBuilder
    private func timeZoneDisplayRows(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            readOnlyRow("PT Time", date, in: "America/Los_Angeles")
            readOnlyRow("MT Time", date, in: "America/Denver")
            readOnlyRow("CT Time", date, in: "America/Chicago")
            readOnlyRow("ET Time", date, in: "America/New_York")
        }
        .padding(.vertical, 4)
    }
    
    private func readOnlyRow(_ label: String, _ date: Date, in tzID: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(formatDateTime(date, tzID))
                .foregroundColor(.secondary)
        }
    }
    
    private func formatDateTime(_ date: Date, _ tzID: String) -> String {
        guard let tz = TimeZone(identifier: tzID) else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = tz
        return formatter.string(from: date)
    }
}
