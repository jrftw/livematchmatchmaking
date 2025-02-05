// MARK: - LeaderboardsView.swift
// Displays global leaderboards by fetching real data from Firestore.

import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public class LeaderboardViewModel: ObservableObject {
    public struct LeaderboardEntry: Identifiable {
        public let id: String
        public let username: String
        public let totalScore: Int
        public let loginStreak: Int
    }
    
    @Published public var entries: [LeaderboardEntry] = []
    
    public init() {}
    
    public func fetchLeaderboard() {
        let db = Firestore.firestore()
        
        db.collection("users")
            .order(by: "totalScore", descending: true)
            .limit(to: 100)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("[LeaderboardViewModel] Error fetching leaderboard: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("[LeaderboardViewModel] No documents found.")
                    return
                }
                
                let newEntries = docs.compactMap { doc -> LeaderboardEntry? in
                    let data = doc.data()
                    guard let username = data["username"] as? String else { return nil }
                    let totalScore = data["totalScore"] as? Int ?? 0
                    let streak = data["loginStreak"] as? Int ?? 0
                    
                    return LeaderboardEntry(
                        id: doc.documentID,
                        username: username,
                        totalScore: totalScore,
                        loginStreak: streak
                    )
                }
                
                DispatchQueue.main.async {
                    self.entries = newEntries
                }
            }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LeaderboardsView: View {
    @ObservedObject private var viewModel = LeaderboardViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 10) {
            Text("Leaderboards")
                .font(.largeTitle)
                .padding(.top, 20)
            
            Text("Check your rank and compare scores!")
                .foregroundColor(.secondary)
            
            if !viewModel.entries.isEmpty {
                Text("Total on Leaderboard: \(viewModel.entries.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if viewModel.entries.isEmpty {
                Spacer()
                Text("No leaderboard entries available.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { (index, entry) in
                        HStack {
                            Text("\(index + 1). \(entry.username)")
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(entry.totalScore) pts")
                                    .fontWeight(.semibold)
                                Text("Streak: \(entry.loginStreak)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            Spacer()
        }
        .onAppear {
            viewModel.fetchLeaderboard()
        }
    }
}
