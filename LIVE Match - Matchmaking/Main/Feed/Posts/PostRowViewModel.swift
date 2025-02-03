// MARK: - PostRowViewModel.swift
// Already included above. Shown again for completeness.

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
            // Must match your user doc field. E.g., "profilePictureURL"
            self.profilePicURL = data["profilePictureURL"] as? String
        }
    }
}
