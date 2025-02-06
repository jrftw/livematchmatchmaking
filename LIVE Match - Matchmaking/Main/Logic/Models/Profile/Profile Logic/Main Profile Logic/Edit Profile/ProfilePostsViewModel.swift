// MARK: ProfilePostsViewModel.swift
// A separate file for ProfilePostsViewModel

import SwiftUI
import FirebaseFirestore

public final class ProfilePostsViewModel: ObservableObject {
    @Published public var posts: [Post] = []
    private let db = FirebaseManager.shared.db
    
    public init(userId: String?) {
        guard let userId = userId else { return }
        fetchPosts(for: userId)
    }
    
    private func fetchPosts(for userId: String) {
        db.collection("posts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else {
                    self.posts = []
                    return
                }
                self.posts = docs.compactMap { try? $0.data(as: Post.self) }
            }
    }
}
