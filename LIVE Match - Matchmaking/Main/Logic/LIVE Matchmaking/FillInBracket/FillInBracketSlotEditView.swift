//
//  FillInBracketSlotEditView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A subview for editing one bracket slot.

import SwiftUI
import Foundation

// MARK: - FillInBracketSlotEditView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketSlotEditView: View {
    @State var slot: FillInBracketSlot
    var onSave: ((FillInBracketSlot) -> Void)?
    var onCancel: (() -> Void)?
    
    public init(
        slot: FillInBracketSlot,
        onSave: ((FillInBracketSlot) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._slot = State(initialValue: slot)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date & Time")) {
                    DatePicker("Select Date/Time", selection: $slot.startDateTime, displayedComponents: [.date, .hourAndMinute])
                    timeZoneDisplayRows(for: slot.startDateTime)
                }
                Section(header: Text("Creator #1")) {
                    TextField("Name", text: $slot.creator1)
                    TextField("Network/Agency (Optional)", text: $slot.creatorNetworkOrAgency1)
                    TextField("Category", text: $slot.category1)
                    TextField("Diamond Avg", text: $slot.diamondAvg1)
                }
                Section(header: Text("Creator #2")) {
                    TextField("Name", text: $slot.creator2)
                    TextField("Network/Agency (Optional)", text: $slot.creatorNetworkOrAgency2)
                    TextField("Category", text: $slot.category2)
                    TextField("Diamond Avg", text: $slot.diamondAvg2)
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
    }
    
    // MARK: TimeZone Display
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
