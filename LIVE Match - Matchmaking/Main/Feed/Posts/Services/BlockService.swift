//
//  BlockService.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/5/25.
//

// MARK: - BlockService.swift
// Handles blocking/unblocking a user using Firebase.

import Foundation
import Firebase
import FirebaseAuth

public class BlockService {
    // MARK: - Shared
    public static let shared = BlockService()
    
    private init() {}
    
    // MARK: - Methods
    
    // MARK: Block User
    public func blockUser(userId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let blockedRef = db.collection("users")
            .document(currentUser.uid)
            .collection("blockedUsers")
            .document(userId)
        
        blockedRef.setData(["blocked": true]) { error in
            if let error = error {
                print("Error blocking user: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: Unblock User
    public func unblockUser(userId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let blockedRef = db.collection("users")
            .document(currentUser.uid)
            .collection("blockedUsers")
            .document(userId)
        
        blockedRef.delete { error in
            if let error = error {
                print("Error unblocking user: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: Check If User Is Blocked
    public func isUserBlocked(userId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let blockedRef = db.collection("users")
            .document(currentUser.uid)
            .collection("blockedUsers")
            .document(userId)
        
        blockedRef.getDocument { snapshot, _ in
            if let data = snapshot?.data(), data["blocked"] as? Bool == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
