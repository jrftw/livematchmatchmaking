// MARK: FeedViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class FeedViewModel: ObservableObject {
    @Published public var posts: [Post] = []
    private let db = FirebaseManager.shared.db
    
    public init() {}
    
    public func fetchPosts() {
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.posts = docs.compactMap { try? $0.data(as: Post.self) }
            }
    }
    
    public func createPost(text: String, imageURL: String? = nil, videoURL: String? = nil) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), error == nil {
                let realUsername = data["name"] as? String ?? "Unknown"
                self.finishCreatePost(
                    userId: uid,
                    username: realUsername,
                    text: text,
                    imageURL: imageURL,
                    videoURL: videoURL
                )
            } else {
                self.finishCreatePost(
                    userId: uid,
                    username: "User",
                    text: text,
                    imageURL: imageURL,
                    videoURL: videoURL
                )
            }
        }
    }
    
    private func finishCreatePost(
        userId: String,
        username: String,
        text: String,
        imageURL: String?,
        videoURL: String?
    ) {
        let newPost = Post(
            userId: userId,
            username: username,
            text: text,
            imageURL: imageURL,
            videoURL: videoURL,
            timestamp: Date()
        )
        do {
            _ = try db.collection("posts").addDocument(from: newPost)
        } catch {
            print("Error creating post: \(error.localizedDescription)")
        }
    }
}
