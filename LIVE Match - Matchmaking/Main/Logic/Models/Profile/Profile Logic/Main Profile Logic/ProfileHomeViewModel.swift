// MARK: - ProfileHomeViewModel.swift
// Fetches the full MyUserProfile from Firestore, including all scopes/fields.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ProfileHomeViewModel: ObservableObject {
    @Published public var profile: MyUserProfile = MyUserProfile(
        id: nil,
        firstName: "",
        lastName: "",
        displayName: "",
        username: "",
        tags: [],
        socialLinks: [:],
        createdAt: Date(),
        followersCount: 0,
        followingCount: 0,
        wins: 0,
        losses: 0
    )
    @Published public var isLoading = true
    @Published public var errorMessage: String? = nil
    
    private var userID: String?
    
    public init(userID: String? = nil) {
        self.userID = userID
        fetchProfile()
    }
    
    /// Fetch MyUserProfile from Firestore, retrieving all defined fields.
    private func fetchProfile() {
        let db = Firestore.firestore()
        
        let finalUserID: String
        if let uid = userID {
            finalUserID = uid
        } else if let currentUID = Auth.auth().currentUser?.uid {
            finalUserID = currentUID
        } else {
            self.errorMessage = "No userID and no current user."
            self.isLoading = false
            return
        }
        
        db.collection("users").document(finalUserID).getDocument { snap, err in
            DispatchQueue.main.async {
                self.isLoading = false
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    return
                }
                guard let doc = snap, doc.exists, let data = doc.data() else {
                    self.errorMessage = "No profile found for userID \(finalUserID)."
                    return
                }
                
                var parsed = MyUserProfile(
                    id: doc.documentID,
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    bio: data["bio"] as? String,
                    birthday: data["birthday"] as? String,
                    birthdayPublicly: data["birthdayPublicly"] as? Bool ?? false,
                    email: data["email"] as? String,
                    emailPublicly: data["emailPublicly"] as? Bool ?? false,
                    phoneNumber: data["phoneNumber"] as? String,
                    phonePublicly: data["phonePublicly"] as? Bool ?? false,
                    clanTag: data["clanTag"] as? String,
                    clanColorHex: data["clanColorHex"] as? String,
                    tags: data["tags"] as? [String] ?? [],
                    socialLinks: data["socialLinks"] as? [String: String] ?? [:],
                    profilePictureURL: data["profilePictureURL"] as? String,
                    bannerURL: data["bannerURL"] as? String,
                    createdAt: Date(),
                    followersCount: data["followersCount"] as? Int ?? 0,
                    followingCount: data["followingCount"] as? Int ?? 0,
                    wins: data["wins"] as? Int ?? 0,
                    losses: data["losses"] as? Int ?? 0
                )
                // If Firestore has a timestamp for `createdAt`, parse it
                if let ts = data["createdAt"] as? Timestamp {
                    parsed.createdAt = ts.dateValue()
                }
                
                self.profile = parsed
            }
        }
    }
}
