//
//  FillInBracketSlotsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//


// FILE: FillInBracketSlotsView.swift
// NEW FILE CREATED

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketSlotsView: View {
    public let bracket: FillInBracketDoc
    @StateObject private var vm: FillInBracketSlotsViewModel
    
    public init(bracket: FillInBracketDoc) {
        self.bracket = bracket
        _vm = StateObject(wrappedValue: FillInBracketSlotsViewModel(bracket: bracket))
    }
    
    public var body: some View {
        List {
            if vm.slots.isEmpty {
                Text("No slots found in this bracket.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(vm.slots) { slot in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(slot.creator1.isEmpty ? "?" : slot.creator1) vs \(slot.creator2.isEmpty ? "?" : slot.creator2)")
                            .font(.headline)
                        Text("Date: \(vm.formatDateTime(slot.startDateTime))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Status: \(slot.status.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(colorForStatus(slot.status))
                        
                        if canJoinSlot(slot) {
                            HStack(spacing: 10) {
                                if slot.creator1.isEmpty {
                                    Button("Join as Creator #1") {
                                        vm.joinSlot(slot: slot, asCreator1: true)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                if slot.creator2.isEmpty {
                                    Button("Join as Creator #2") {
                                        vm.joinSlot(slot: slot, asCreator1: false)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle(bracket.bracketName)
        .onAppear {
            vm.loadBracketSlots()
        }
    }
    
    private func canJoinSlot(_ slot: FillInBracketSlot) -> Bool {
        (slot.creator1.isEmpty || slot.creator2.isEmpty)
    }
    
    private func colorForStatus(_ status: MatchStatus) -> Color {
        switch status {
        case .confirmed: return .green
        case .declined:  return .red
        case .pending:   return .orange
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class FillInBracketSlotsViewModel: ObservableObject {
    @Published var slots: [FillInBracketSlot] = []
    let bracket: FillInBracketDoc
    private let db = FirebaseManager.shared.db
    
    init(bracket: FillInBracketDoc) {
        self.bracket = bracket
    }
    
    func loadBracketSlots() {
        slots = bracket.slots
    }
    
    func joinSlot(slot: FillInBracketSlot, asCreator1: Bool) {
        guard let user = Auth.auth().currentUser else {
            print("User must be logged in to join a slot.")
            return
        }
        
        var newSlots = slots
        guard let slotIndex = newSlots.firstIndex(where: { $0.id == slot.id }) else { return }
        
        let displayName = user.displayName ?? "UnknownUser"
        
        if asCreator1 && newSlots[slotIndex].creator1.isEmpty {
            newSlots[slotIndex].creator1 = displayName
        } else if !asCreator1 && newSlots[slotIndex].creator2.isEmpty {
            newSlots[slotIndex].creator2 = displayName
        } else {
            print("Cannot join slot; field is already filled.")
            return
        }
        
        guard let bracketID = bracket.id else {
            print("Bracket has no valid doc ID; cannot update.")
            return
        }
        
        do {
            let ref = db.collection("fillInBrackets").document(bracketID)
            let encodedSlots = try newSlots.map { try JSONEncoder().encode($0) }
            let dictSlots = encodedSlots.compactMap { data -> [String: Any]? in
                (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            }
            
            ref.updateData(["slots": dictSlots]) { [weak self] err in
                if let err = err {
                    print("Error updating bracket slots: \(err.localizedDescription)")
                } else {
                    print("Successfully joined slot in bracket.")
                    self?.slots = newSlots
                }
            }
        } catch {
            print("Error encoding slot: \(error.localizedDescription)")
        }
    }
    
    func formatDateTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}