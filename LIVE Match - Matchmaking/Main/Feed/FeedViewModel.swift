// MARK: - FeedViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Accepts multiple images, optional video URL, and tagged users.
// Make sure your user doc has "username" and "profilePictureURL" if you want them visible.

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
    
    // MARK: Create a new post from text, images, optional video, and tagged users
    public func createPost(
        text: String,
        images: [UIImage],
        videoURL: URL?,
        taggedUsers: [String]
    ) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        // Fetch the "username" (or "displayName") from Firestore
        db.collection("users").document(uid).getDocument { snapshot, error in
            // Replace "username" below with whichever field you actually store
            // If you store "displayName", use snapshot?.data()?["displayName"]
            let realUsername = snapshot?.data()?["username"] as? String ?? "Unknown"
            
            // In production:
            // 1) Upload each image => get array of image URLs
            // 2) Upload the video => get a URL
            // 3) Pass them to finishCreatePost
            self.finishCreatePost(
                userId: uid,
                username: realUsername,
                text: text,
                // placeholders for imageURL & videoURL
                // Real logic would handle an array for multiple images
                imageURL: nil,
                videoURL: nil,
                taggedUsers: taggedUsers
            )
        }
    }
    
    private func finishCreatePost(
        userId: String,
        username: String,
        text: String,
        imageURL: String?,
        videoURL: String?,
        taggedUsers: [String]
    ) {
        let newPost = Post(
            userId: userId,
            username: username,
            text: text,
            imageURL: imageURL,
            videoURL: videoURL,
            timestamp: Date(),
            category: "Everyone", // Adjust as needed
            taggedUsers: taggedUsers
        )
        
        do {
            _ = try db.collection("posts").addDocument(from: newPost)
        } catch {
            print("Error creating post: \(error.localizedDescription)")
        }
    }
}
