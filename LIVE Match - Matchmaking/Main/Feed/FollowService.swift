// MARK: - FollowService.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Manages following/unfollowing logic between users.

import Foundation
import Firebase
import FirebaseAuth

public final class FollowService {
    public static let shared = FollowService()
    private let db = FirebaseManager.shared.db
    
    private init() {}
    
    public func followUser(targetUserId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let currentUserFollowingRef = db.collection("users")
            .document(currentUser.uid)
            .collection("following")
            .document(targetUserId)
        
        let targetUserFollowersRef = db.collection("users")
            .document(targetUserId)
            .collection("followers")
            .document(currentUser.uid)
        
        let data: [String: Any] = ["followedAt": Timestamp(date: Date())]
        
        let batch = db.batch()
        batch.setData(data, forDocument: currentUserFollowingRef)
        batch.setData(data, forDocument: targetUserFollowersRef)
        
        batch.commit { error in
            if let error = error {
                print("Follow error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    public func unfollowUser(targetUserId: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let currentUserFollowingRef = db.collection("users")
            .document(currentUser.uid)
            .collection("following")
            .document(targetUserId)
        
        let targetUserFollowersRef = db.collection("users")
            .document(targetUserId)
            .collection("followers")
            .document(currentUser.uid)
        
        let batch = db.batch()
        batch.deleteDocument(currentUserFollowingRef)
        batch.deleteDocument(targetUserFollowersRef)
        
        batch.commit { error in
            if let error = error {
                print("Unfollow error: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
