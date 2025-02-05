// MARK: - CommentService.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Manages creating and fetching comments for posts.

import Foundation
import Firebase
import FirebaseAuth

public struct Comment: Identifiable {
    public var id: String?
    public var postId: String
    public var userId: String
    public var username: String
    public var text: String
    public var timestamp: Date
    
    public init(
        id: String? = nil,
        postId: String,
        userId: String,
        username: String,
        text: String,
        timestamp: Date
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}

public final class CommentService: ObservableObject {
    public static let shared = CommentService()
    private let db = FirebaseManager.shared.db
    
    private init() {}
    
    public func addComment(postId: String, commentText: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let commentRef = db.collection("posts")
            .document(postId)
            .collection("comments")
            .document()
        
        let newId = commentRef.documentID
        let username = user.displayName ?? "User"
        
        let commentData: [String: Any] = [
            "id": newId,
            "postId": postId,
            "userId": user.uid,
            "username": username,
            "text": commentText,
            "timestamp": Timestamp(date: Date())
        ]
        
        commentRef.setData(commentData) { error in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    public func fetchComments(postId: String, completion: @escaping ([Comment]) -> Void) {
        db.collection("posts")
            .document(postId)
            .collection("comments")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    completion([])
                    return
                }
                var allComments: [Comment] = []
                for doc in docs {
                    let data = doc.data()
                    let id = data["id"] as? String ?? doc.documentID
                    let postId = data["postId"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let username = data["username"] as? String ?? "User"
                    let text = data["text"] as? String ?? ""
                    let ts = data["timestamp"] as? Timestamp
                    let timestamp = ts?.dateValue() ?? Date()
                    
                    let comment = Comment(
                        id: id,
                        postId: postId,
                        userId: userId,
                        username: username,
                        text: text,
                        timestamp: timestamp
                    )
                    allComments.append(comment)
                }
                completion(allComments)
            }
    }
}
