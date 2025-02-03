// MARK: - LikeService.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Manages liking/unliking posts.

import Foundation
import Firebase
import FirebaseAuth

public final class LikeService {
    public static let shared = LikeService()
    private let db = FirebaseManager.shared.db
    
    private init() {}
    
    public func likePost(postId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let likeDoc = db.collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
        
        let data: [String: Any] = ["likedAt": Timestamp(date: Date())]
        
        likeDoc.setData(data) { error in
            if let error = error {
                print("Error liking post: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    public func unlikePost(postId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let likeDoc = db.collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
        
        likeDoc.delete { error in
            if let error = error {
                print("Error unliking post: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
