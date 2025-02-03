//
//  CreatorStudioViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: CreatorStudioViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Stores each CreatorPlatform in the user doc under "creatorPlatforms".

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class CreatorStudioViewModel: ObservableObject {
    @Published var platforms: [CreatorPlatform] = [
        .init(name: "TikTok"),
        .init(name: "Favorited"),
        .init(name: "Mango"),
        .init(name: "LIVE.Me"),
        .init(name: "YouNow"),
        .init(name: "YouTube"),
        .init(name: "Clapper"),
        .init(name: "Fanbase"),
        .init(name: "Kick"),
        .init(name: "Other")
    ]
    
    private let db = FirebaseManager.shared.db
    private var userID: String? { Auth.auth().currentUser?.uid }
    
    public init() {}
    
    public func loadFromFirestore() {
        guard let uid = userID else { return }
        db.collection("users").document(uid).getDocument { doc, error in
            guard let data = doc?.data(), error == nil else { return }
            
            if let stored = data["creatorPlatforms"] as? [[String: Any]] {
                for i in stored.indices {
                    if i < self.platforms.count {
                        let dict = stored[i]
                        self.platforms[i].enabled    = dict["enabled"] as? Bool ?? false
                        self.platforms[i].username   = dict["username"] as? String ?? ""
                        self.platforms[i].profileLink = dict["profileLink"] as? String ?? ""
                        self.platforms[i].inAgency   = dict["inAgency"] as? Bool ?? false
                        self.platforms[i].agencyName = dict["agencyName"] as? String ?? ""
                    }
                }
            }
        }
    }
    
    public func saveToFirestore() {
        guard let uid = userID else { return }
        let mapped = platforms.map { $0.asDictionary() }
        
        db.collection("users").document(uid).setData([
            "creatorPlatforms": mapped
        ], merge: true) { error in
            if let error = error {
                print("Error saving creator platforms: \(error.localizedDescription)")
            } else {
                print("Creator platforms saved successfully.")
            }
        }
    }
}