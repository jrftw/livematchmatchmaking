//
//  CommentListViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/10/25.
//


// MARK: - CommentListViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Handles retrieving all comments in real-time for a given post.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class CommentListViewModel: ObservableObject {
    @Published public var comments: [Comment] = []
    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?
    private var postId: String
    
    public init(postId: String) {
        self.postId = postId
        listenForComments()
    }
    
    private func listenForComments() {
        listener = db.collection("posts")
            .document(postId)
            .collection("comments")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for comments: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else {
                    self.comments = []
                    return
                }
                self.comments = docs.map { doc in
                    let data = doc.data()
                    let id = data["id"] as? String ?? doc.documentID
                    let postId = data["postId"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let username = data["username"] as? String ?? "User"
                    let text = data["text"] as? String ?? ""
                    let ts = data["timestamp"] as? Timestamp
                    let timestamp = ts?.dateValue() ?? Date()
                    
                    return Comment(
                        id: id,
                        postId: postId,
                        userId: userId,
                        username: username,
                        text: text,
                        timestamp: timestamp
                    )
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}