// FILE: MyBracketsViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Fetches all brackets created by the current user.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class MyBracketsViewModel: ObservableObject {
    @Published var brackets: [BracketDoc] = []
    
    private let db = FirebaseManager.shared.db
    
    func fetchMyBrackets() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in; cannot fetch brackets.")
            return
        }
        
        // 1. Fetch user doc to get the username
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user doc: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                print("User doc does not exist in Firestore.")
                return
            }
            
            do {
                let profile = try snapshot.data(as: UserProfile.self)
                let creatorName = profile.username
                
                // 2. Query 'brackets' collection for documents where 'bracketCreator' == creatorName
                self.db.collection("brackets")
                    .whereField("bracketCreator", isEqualTo: creatorName)
                    .getDocuments { snap, err in
                        if let err = err {
                            print("Error fetching brackets: \(err.localizedDescription)")
                            return
                        }
                        guard let docs = snap?.documents else { return }
                        
                        // 3. Decode each document into BracketDoc
                        let fetched = docs.compactMap { doc -> BracketDoc? in
                            try? doc.data(as: BracketDoc.self)
                        }
                        DispatchQueue.main.async {
                            self.brackets = fetched
                        }
                    }
            } catch {
                print("Error decoding user profile: \(error.localizedDescription)")
            }
        }
    }
}
