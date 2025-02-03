//
//  ChatViewModel.swift
//  LIVE Match - Matchmaking
//
//  Listens to Firestore "messages" and caches user profiles by UID.
//  Reads "username" (plus other fields) from each user's doc in "users" collection.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ChatViewModel: ObservableObject {
    @Published public var messages: [ChatMessage] = []
    @Published public var userProfiles: [String: MyUserProfile] = [:]  // UID -> MyUserProfile
    
    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?
    
    public init() {}
    
    public func fetchMessages() {
        // Listen to "messages" collection sorted by "timestamp"
        listener = db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                
                if let err = err {
                    print("Error fetching messages: \(err.localizedDescription)")
                    return
                }
                guard let docs = snap?.documents else { return }
                
                var loaded: [ChatMessage] = []
                for document in docs {
                    let data = document.data()
                    let docID = document.documentID
                    let text = data["text"] as? String ?? ""
                    let senderUID = data["senderUID"] as? String ?? "unknownUID"
                    
                    let ts = data["timestamp"] as? Timestamp
                    let timestamp = ts?.dateValue() ?? Date()
                    
                    let msg = ChatMessage(
                        id: docID,
                        text: text,
                        senderUID: senderUID,
                        timestamp: timestamp
                    )
                    loaded.append(msg)
                    
                    // If we haven't fetched this user's doc yet, fetch now
                    if self.userProfiles[senderUID] == nil {
                        self.fetchUserProfile(uid: senderUID)
                    }
                }
                self.messages = loaded
            }
    }
    
    private func fetchUserProfile(uid: String) {
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { [weak self] docSnap, err in
            guard let self = self else { return }
            
            if let err = err {
                print("Error fetching user doc for uid=\(uid): \(err.localizedDescription)")
            }
            
            guard let data = docSnap?.data(), docSnap?.exists == true else {
                print("No user doc found for uid=\(uid). Using fallback MyUserProfile.")
                let fallback = MyUserProfile(
                    id: uid,
                    firstName: "",
                    lastName: "",
                    displayName: "Unknown",
                    username: "unknownUser",
                    bio: nil,
                    birthday: nil,
                    birthdayPublicly: false,
                    email: nil,
                    emailPublicly: false,
                    phoneNumber: nil,
                    phonePublicly: false,
                    clanTag: nil,
                    clanColorHex: nil,
                    tags: [],
                    socialLinks: [:],
                    profilePictureURL: nil,
                    bannerURL: nil,
                    createdAt: Date()
                )
                DispatchQueue.main.async {
                    self.userProfiles[uid] = fallback
                }
                return
            }
            
            // DEBUG: See exactly which fields are stored
            print("User doc for uid=\(uid) =>", data)
            
            // Parse all relevant fields, including "username"
            var user = MyUserProfile(
                id: uid,
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
                createdAt: Date()
            )
            if let ts = data["createdAt"] as? Timestamp {
                user.createdAt = ts.dateValue()
            }
            
            DispatchQueue.main.async {
                self.userProfiles[uid] = user
            }
        }
    }
    
    public func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let docData: [String: Any] = [
                "text": text,
                "senderUID": uid,
                "timestamp": Date()
            ]
            db.collection("messages").addDocument(data: docData)
        }
        else if AuthManager.shared.isGuest {
            let docData: [String: Any] = [
                "text": text,
                "senderUID": "guestUID",
                "timestamp": Date()
            ]
            db.collection("messages").addDocument(data: docData)
        }
    }
    
    deinit {
        listener?.remove()
    }
}
