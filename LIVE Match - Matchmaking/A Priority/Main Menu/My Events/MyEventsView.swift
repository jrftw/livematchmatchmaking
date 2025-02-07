//
//  MyEventsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//
// MARK: MyEventsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays upcoming and completed "confirmed" slots for the current user.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MyEventsView: View {
    @StateObject private var vm = MyEventsViewModel()
    
    public init() {}
    
    // Separate upcoming vs completed by comparing slot startDateTime with Date()
    private var upcomingEvents: [ConfirmedSlotEvent] {
        vm.events.filter { $0.startDateTime > Date() }
    }
    private var completedEvents: [ConfirmedSlotEvent] {
        vm.events.filter { $0.startDateTime <= Date() }
    }
    
    public var body: some View {
        NavigationView {
            List {
                // MARK: - Upcoming Section
                Section("Upcoming Events") {
                    if upcomingEvents.isEmpty {
                        Text("No upcoming events.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(upcomingEvents) { event in
                            eventRow(for: event)
                        }
                    }
                }
                
                // MARK: - Completed Section
                Section("Completed Events") {
                    if completedEvents.isEmpty {
                        Text("No completed events.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(completedEvents) { event in
                            eventRow(for: event)
                        }
                    }
                }
            }
            .navigationTitle("My Events")
        }
        .onAppear {
            vm.loadMyConfirmedSlots()
        }
    }
    
    // A small helper to avoid repeating code in each section
    private func eventRow(for event: ConfirmedSlotEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.bracketName)
                .font(.headline)
            Text("\(event.creator1) vs \(event.creator2)")
                .font(.subheadline)
                .foregroundColor(.primary)
            Text("Time: \(vm.formatDateTime(event.startDateTime))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class MyEventsViewModel: ObservableObject {
    @Published var events: [ConfirmedSlotEvent] = []
    private let db = FirebaseManager.shared.db
    
    func loadMyConfirmedSlots() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User must be logged in to see events.")
            return
        }
        
        db.collection("fillInBrackets").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching brackets for MyEvents: \(error.localizedDescription)")
                return
            }
            guard let docs = snapshot?.documents else { return }
            
            var temp: [ConfirmedSlotEvent] = []
            let displayName = currentUser.displayName ?? ""
            
            for doc in docs {
                do {
                    let bracketDoc = try doc.data(as: FillInBracketDoc.self)
                    
                    // For each bracket, check each slot
                    for slot in bracketDoc.slots {
                        // Check if slot is 'confirmed' AND user is in slot
                        if slot.status == .confirmed {
                            if slot.creator1 == displayName || slot.creator2 == displayName {
                                let event = ConfirmedSlotEvent(
                                    bracketName: bracketDoc.bracketName,
                                    startDateTime: slot.startDateTime,
                                    creator1: slot.creator1,
                                    creator2: slot.creator2
                                )
                                temp.append(event)
                            }
                        }
                    }
                } catch {
                    print("Error decoding bracket in MyEvents: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                self?.events = temp
            }
        }
    }
    
    func formatDateTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}

// MARK: - ConfirmedSlotEvent
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ConfirmedSlotEvent: Identifiable {
    let id = UUID()
    let bracketName: String
    let startDateTime: Date
    let creator1: String
    let creator2: String
}
