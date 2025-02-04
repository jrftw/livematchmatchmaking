// MARK: - PostRowViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Handles user profile pic, like status, follow status, etc.
// This does NOT force the user to like, comment, or follow anyone;
// it only watches for current statuses (liked/following) and displays them.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class PostRowViewModel: ObservableObject {
    @Published public var profilePicURL: String?
    @Published public var isLiked = false
    @Published public var isFollowing = false
    
    private let db = FirebaseManager.shared.db
    private var userId: String
    private var postId: String?
    
    public init(userId: String, postId: String?) {
        self.userId = userId
        self.postId = postId
        fetchProfilePic()
        watchLikeStatus()
        watchFollowStatus()
    }
    
    private func fetchProfilePic() {
        db.collection("users").document(userId).addSnapshotListener { doc, _ in
            guard let data = doc?.data() else { return }
            self.profilePicURL = data["profilePictureURL"] as? String
        }
    }
    
    private func watchLikeStatus() {
        guard let uid = Auth.auth().currentUser?.uid,
              let postId = postId else { return }
        
        db.collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
            .addSnapshotListener { snap, _ in
                if let s = snap, s.exists {
                    self.isLiked = true
                } else {
                    self.isLiked = false
                }
            }
    }
    
    private func watchFollowStatus() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(currentUserId)
            .collection("following")
            .document(userId)
            .addSnapshotListener { snap, _ in
                if let s = snap, s.exists {
                    self.isFollowing = true
                } else {
                    self.isFollowing = false
                }
            }
    }
}
