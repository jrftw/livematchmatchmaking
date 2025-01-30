//
//  PostRowViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: PostRowViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Fetches the user's profile pic to display in the feed.

import SwiftUI
import Firebase

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class PostRowViewModel: ObservableObject {
    @Published public var profilePicURL: String?
    
    private let db = FirebaseManager.shared.db
    private var userId: String
    
    public init(userId: String) {
        self.userId = userId
        fetchProfilePic()
    }
    
    private func fetchProfilePic() {
        db.collection("users").document(userId).addSnapshotListener { doc, _ in
            guard let data = doc?.data() else { return }
            let pic = data["profilePictureURL"] as? String
            self.profilePicURL = pic
        }
    }
}