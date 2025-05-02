import Foundation
import FirebaseFirestore
import Combine

class MatchService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var matches: [Match] = []
    @Published var error: Error?
    
    func createMatch(_ match: Match) async throws -> String {
        let docRef = try db.collection("matches").addDocument(from: match)
        return docRef.documentID
    }
    
    func updateMatch(_ match: Match) async throws {
        guard let id = match.id else { throw NSError(domain: "MatchService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Match ID is required"]) }
        try db.collection("matches").document(id).setData(from: match)
    }
    
    func deleteMatch(_ matchId: String) async throws {
        try await db.collection("matches").document(matchId).delete()
    }
    
    func joinMatch(_ matchId: String, userId: String) async throws {
        let matchRef = db.collection("matches").document(matchId)
        try await matchRef.updateData([
            "participants": FieldValue.arrayUnion([userId]),
            "currentPlayers": FieldValue.increment(Int64(1))
        ])
    }
    
    func leaveMatch(_ matchId: String, userId: String) async throws {
        let matchRef = db.collection("matches").document(matchId)
        try await matchRef.updateData([
            "participants": FieldValue.arrayRemove([userId]),
            "currentPlayers": FieldValue.increment(Int64(-1))
        ])
    }
    
    func fetchMatches() {
        db.collection("matches")
            .order(by: "startTime", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self?.matches = documents.compactMap { try? $0.data(as: Match.self) }
            }
    }
    
    func fetchMatchesForUser(_ userId: String) {
        db.collection("matches")
            .whereField("participants", arrayContains: userId)
            .order(by: "startTime", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self?.matches = documents.compactMap { try? $0.data(as: Match.self) }
            }
    }
} 
