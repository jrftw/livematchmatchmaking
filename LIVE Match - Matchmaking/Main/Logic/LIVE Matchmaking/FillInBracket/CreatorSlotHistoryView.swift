//
//  CreatorSlotHistoryView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/6/25.
//


// FILE: CreatorSlotHistoryView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------
// This view shows a history of all slots the current user has joined.
// We fetch all fillInBrackets from Firestore, then filter for those
// where the current user's displayName is either in creator1 or creator2.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorSlotHistoryView: View {
    @StateObject private var vm = CreatorSlotHistoryViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                if vm.joinedSlots.isEmpty {
                    Text("No slot history found for your account.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(vm.joinedSlots) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.bracketName)")
                                .font(.headline)
                            Text("Slot: \(item.slot.creator1.isEmpty ? "?" : item.slot.creator1) vs \(item.slot.creator2.isEmpty ? "?" : item.slot.creator2)")
                                .font(.subheadline)
                            Text("Status: \(item.slot.status.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Slot History")
        }
        .onAppear {
            vm.loadCreatorHistory()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class CreatorSlotHistoryViewModel: ObservableObject {
    @Published var joinedSlots: [JoinedSlotItem] = []
    
    func loadCreatorHistory() {
        guard let user = Auth.auth().currentUser else {
            print("User must be logged in to see slot history.")
            joinedSlots = []
            return
        }
        
        let displayName = user.displayName ?? "User-\(user.uid.prefix(4))"
        let db = FirebaseManager.shared.db
        
        db.collection("fillInBrackets")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching brackets for history: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                do {
                    let bracketDocs = try docs.compactMap { doc -> FillInBracketDoc? in
                        try doc.data(as: FillInBracketDoc.self)
                    }
                    
                    var result: [JoinedSlotItem] = []
                    
                    // Filter slots for the user
                    for bracket in bracketDocs {
                        for slot in bracket.slots {
                            if slot.creator1 == displayName || slot.creator2 == displayName {
                                // user participated in this slot
                                let item = JoinedSlotItem(bracketName: bracket.bracketName, slot: slot)
                                result.append(item)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.joinedSlots = result
                    }
                } catch {
                    print("Error decoding bracket docs: \(error.localizedDescription)")
                }
            }
    }
}

// A simple struct tying a bracket name to the slot the user joined
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct JoinedSlotItem: Identifiable {
    let id = UUID()
    let bracketName: String
    let slot: FillInBracketSlot
}