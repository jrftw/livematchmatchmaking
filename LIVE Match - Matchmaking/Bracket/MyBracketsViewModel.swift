//
//  MyBracketsViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: MyBracketsViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Observes and fetches bracket documents belonging to the current user.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class MyBracketsViewModel: ObservableObject {
    @Published var brackets: [BracketDoc] = []
    
    private let db = FirebaseManager.shared.db
    
    func fetchMyBrackets() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { doc, err in
            guard let doc = doc, doc.exists else { return }
            do {
                let profile = try doc.data(as: UserProfile.self)
                let creatorName = profile.name
                
                self.db.collection("brackets")
                    .whereField("bracketCreator", isEqualTo: creatorName)
                    .getDocuments { snap, error in
                        if let error = error {
                            print("Error fetching brackets: \(error.localizedDescription)")
                            return
                        }
                        guard let docs = snap?.documents else { return }
                        
                        let fetched = docs.compactMap { d -> BracketDoc? in
                            try? d.data(as: BracketDoc.self)
                        }
                        DispatchQueue.main.async {
                            self.brackets = fetched
                        }
                    }
            } catch {
                print("Error decoding userProfile: \(error.localizedDescription)")
            }
        }
    }
}
