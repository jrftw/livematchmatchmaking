// FILE: FillInBracketSlotsView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// -------------------------------------------------------
// A view showing the slots in a bracket. Users can join as Creator1/Creator2.
// Both users must "Confirm" for the slot status to become .confirmed.
// The bracket remains visible; it does not disappear after someone joins.

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
                        
                        // Show "Join" buttons if open
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
                        
                        // If user is in this slot, show "Confirm" button to finalize
                        if vm.canConfirmSlot(slot) {
                            Button("Confirm Slot") {
                                vm.confirmSlot(slot)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.top, 6)
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
    
    // Called when user clicks "Join as Creator #1" or "Join as Creator #2"
    func joinSlot(slot: FillInBracketSlot, asCreator1: Bool) {
        guard let user = Auth.auth().currentUser else {
            print("User must be logged in to join a slot.")
            return
        }
        
        var newSlots = slots
        guard let index = newSlots.firstIndex(where: { $0.id == slot.id }) else { return }
        
        let displayName = user.displayName ?? "User-\(user.uid.prefix(4))"
        
        if asCreator1 && newSlots[index].creator1.isEmpty {
            newSlots[index].creator1 = displayName
            newSlots[index].creator1Confirmed = false // reset their confirm state
        } else if !asCreator1 && newSlots[index].creator2.isEmpty {
            newSlots[index].creator2 = displayName
            newSlots[index].creator2Confirmed = false
        } else {
            print("Cannot join slot; the spot is already filled.")
            return
        }
        
        // The slot remains .pending if at least one spot was empty
        newSlots[index].status = .pending
        
        updateSlotsInFirestore(newSlots)
    }
    
    // Called when a user wants to finalize their participation
    // Both participants must confirm for status = .confirmed
    func confirmSlot(_ slot: FillInBracketSlot) {
        guard let user = Auth.auth().currentUser else {
            print("User must be logged in to confirm slot.")
            return
        }
        var newSlots = slots
        guard let index = newSlots.firstIndex(where: { $0.id == slot.id }) else { return }
        
        let displayName = user.displayName ?? "User-\(user.uid.prefix(4))"
        // If this user is creator1, set creator1Confirmed = true
        if newSlots[index].creator1 == displayName {
            newSlots[index].creator1Confirmed = true
        }
        // If this user is creator2, set creator2Confirmed = true
        if newSlots[index].creator2 == displayName {
            newSlots[index].creator2Confirmed = true
        }
        
        // If both are filled AND both have confirmed => status = .confirmed
        if !newSlots[index].creator1.isEmpty,
           !newSlots[index].creator2.isEmpty,
           newSlots[index].creator1Confirmed,
           newSlots[index].creator2Confirmed {
            newSlots[index].status = .confirmed
        }
        
        updateSlotsInFirestore(newSlots)
    }
    
    // Checks if the current user can confirm the slot
    // (i.e. the user is either creator1 or creator2, and not yet confirmed).
    func canConfirmSlot(_ slot: FillInBracketSlot) -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        let displayName = user.displayName ?? "User-\(user.uid.prefix(4))"
        
        // If user is creator1 and not yet confirmed
        if slot.creator1 == displayName && !slot.creator1Confirmed {
            return true
        }
        // If user is creator2 and not yet confirmed
        if slot.creator2 == displayName && !slot.creator2Confirmed {
            return true
        }
        return false
    }
    
    // Helper to update bracket slots in Firestore
    private func updateSlotsInFirestore(_ newSlots: [FillInBracketSlot]) {
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
                    print("Bracket slots updated successfully.")
                    self?.slots = newSlots
                }
            }
        } catch {
            print("Error encoding slots: \(error.localizedDescription)")
        }
    }
    
    // Utility for date formatting
    func formatDateTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}
