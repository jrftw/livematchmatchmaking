//
//  ThreadUserSearchViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - ThreadUserSearchViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Fetches all users from Firestore, filters by username search, sorted A-Z.
// Also can add a user to a "thread" by updating participantIDs.

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class ThreadUserSearchViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var allUsers: [UserProfile] = []
    @Published var searchText: String = ""
    
    // MARK: - Filtered
    var filteredUsers: [UserProfile] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return allUsers.sorted { $0.username.lowercased() < $1.username.lowercased() }
        } else {
            return allUsers
                .filter { $0.username.lowercased().contains(trimmed) }
                .sorted { $0.username.lowercased() < $1.username.lowercased() }
        }
    }
    
    // MARK: - Fetch
    func fetchAllUsers() {
        print("[ThreadUserSearchViewModel] fetchAllUsers called.")
        guard Auth.auth().currentUser != nil else {
            print("[ThreadUserSearchViewModel] No authenticated user found.")
            return
        }
        FirebaseManager.shared.db.collection("users")
            .getDocuments { snap, err in
                if let err = err {
                    print("[ThreadUserSearchViewModel] Error fetching all users: \(err.localizedDescription)")
                    return
                }
                guard let docs = snap?.documents else {
                    print("[ThreadUserSearchViewModel] No user documents found.")
                    return
                }
                var loaded: [UserProfile] = []
                for doc in docs {
                    if let user = try? doc.data(as: UserProfile.self) {
                        loaded.append(user)
                    }
                }
                DispatchQueue.main.async {
                    self.allUsers = loaded
                    print("[ThreadUserSearchViewModel] Successfully fetched \(loaded.count) user(s).")
                }
            }
    }
    
    // MARK: - Add Participant
    func addParticipant(_ user: UserProfile, toThreadID threadID: String) {
        print("[ThreadUserSearchViewModel] addParticipant for \(user.username) in thread \(threadID)")
        guard let userID = user.id else {
            print("[ThreadUserSearchViewModel] User has no valid ID.")
            return
        }
        let docRef = FirebaseManager.shared.db.collection("threads").document(threadID)
        docRef.updateData([
            "participantIDs": FieldValue.arrayUnion([userID])
        ]) { err in
            if let err = err {
                print("[ThreadUserSearchViewModel] Error adding participant: \(err.localizedDescription)")
            } else {
                print("[ThreadUserSearchViewModel] Successfully added participant \(user.username) to thread \(threadID).")
            }
        }
    }
}
