// MARK: - PostRowViewModel.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// Handles user profile pic, like status, follow status, comment count, etc.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class PostRowViewModel: ObservableObject {
    @Published public var profilePicURL: String?
    @Published public var isLiked = false
    @Published public var isFollowing = false
    @Published public var commentCount = 0
    
    private let db = FirebaseManager.shared.db
    private var userId: String
    private var postId: String?
    
    public init(userId: String, postId: String?) {
        self.userId = userId
        self.postId = postId
        fetchProfilePic()
        watchLikeStatus()
        watchFollowStatus()
        watchCommentCount()
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
                self.isLiked = (snap?.exists == true)
            }
    }
    
    private func watchFollowStatus() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(currentUserId)
            .collection("following")
            .document(userId)
            .addSnapshotListener { snap, _ in
                self.isFollowing = (snap?.exists == true)
            }
    }
    
    private func watchCommentCount() {
        guard let postId = postId else { return }
        db.collection("posts")
            .document(postId)
            .collection("comments")
            .addSnapshotListener { snapshot, _ in
                self.commentCount = snapshot?.documents.count ?? 0
            }
    }
}
