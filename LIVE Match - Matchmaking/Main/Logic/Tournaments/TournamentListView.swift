//
//  TournamentListView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Shows existing tournaments, allows creation with 1v1, 2v2, or 1v1v1v1.
//
import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TournamentListView: View {
    @StateObject private var vm = TournamentListViewModel()
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationView {
            List(vm.tournaments) { tournament in
                NavigationLink(destination: TournamentDetailView(tournament: tournament)) {
                    Text(tournament.title)
                }
            }
            .navigationTitle("Tournaments / Events")
            .toolbar {
                Button("Add") {
                    showCreateSheet = true
                }
            }
        }
        .onAppear {
            vm.fetchTournaments()
        }
        .sheet(isPresented: $showCreateSheet) {
            TournamentCreationView { title, description, mode in
                vm.createTournament(title: title, description: description, mode: mode)
            }
        }
    }
}

// MARK: - ViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class TournamentListViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    private var db = FirebaseManager.shared.db
    
    func fetchTournaments() {
        db.collection("tournaments").addSnapshotListener { snap, _ in
            guard let docs = snap?.documents else { return }
            self.tournaments = docs.compactMap { try? $0.data(as: Tournament.self) }
        }
    }
    
    func createTournament(title: String, description: String, mode: TournamentMode) {
        let newTournament = Tournament(
            id: nil,
            title: title + " (\(mode.rawValue))",
            description: description,
            participants: [],
            matches: [],
            events: []
        )
        do {
            _ = try db.collection("tournaments").addDocument(from: newTournament)
        } catch {
            print("Error creating tournament: \(error.localizedDescription)")
        }
    }
}
