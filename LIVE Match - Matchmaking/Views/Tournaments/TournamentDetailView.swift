// MARK: File 16: TournamentDetailView.swift
// MARK: Shows details of a specific tournament, bracket generation, events

import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TournamentDetailView: View {
    @State var tournament: Tournament
    @StateObject private var vm = TournamentDetailViewModel()
    
    var body: some View {
        VStack {
            Text(tournament.title)
                .font(.title)
            Text(tournament.description)
            
            List(vm.matches) { match in
                HStack {
                    Text("P1: \(match.player1ID)")
                    Spacer()
                    Text("vs")
                    Spacer()
                    Text("P2: \(match.player2ID)")
                }
            }
            List(vm.events) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                    Text(event.description).font(.subheadline)
                    Text("Date: \(event.date.description)")
                }
            }
            HStack {
                Button("Generate Bracket") {
                    vm.generateBracket(for: tournament)
                }
                Button("Create Event") {
                    vm.createEvent(for: tournament)
                }
            }
        }
        .padding()
        .onAppear {
            vm.observeTournament(tournamentID: tournament.id ?? "")
        }
    }
}

// MARK: TournamentDetailViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class TournamentDetailViewModel: ObservableObject {
    @Published var matches: [TournamentMatch] = []
    @Published var events: [Event] = []
    
    private let db = FirebaseManager.shared.db
    
    func observeTournament(tournamentID: String) {
        guard !tournamentID.isEmpty else { return }
        db.collection("tournaments").document(tournamentID).addSnapshotListener { doc, _ in
            guard let doc = doc else { return }
            do {
                // Remove optional chaining because doc.data(as:) throws on failure
                let t = try doc.data(as: Tournament.self)
                self.matches = t.matches
                self.events = t.events
            } catch {
                print("Error observing tournament: \(error)")
            }
        }
    }
    
    func generateBracket(for tournament: Tournament) {
        guard let id = tournament.id else { return }
        var shuffled = tournament.participants.shuffled()
        var generated: [TournamentMatch] = []
        
        while shuffled.count >= 2 {
            let p1 = shuffled.removeFirst()
            let p2 = shuffled.removeFirst()
            let match = TournamentMatch(
                id: nil,
                player1ID: p1,
                player2ID: p2,
                winnerID: nil,
                isComplete: false
            )
            generated.append(match)
        }
        
        var updated = tournament
        updated.matches = generated
        
        do {
            try db.collection("tournaments").document(id).setData(from: updated)
        } catch {
            print("Error generating bracket: \(error)")
        }
    }
    
    func createEvent(for tournament: Tournament) {
        guard let id = tournament.id else { return }
        let newEvent = Event(
            id: nil,
            title: "New Event",
            date: Date(),
            participants: [],
            description: "Event description"
        )
        var updated = tournament
        var evs = updated.events
        evs.append(newEvent)
        updated.events = evs
        
        do {
            try db.collection("tournaments").document(id).setData(from: updated)
        } catch {
            print("Error creating event: \(error)")
        }
    }
}
