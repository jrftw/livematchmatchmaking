//
//  ThreadMessageService.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Manages sending messages, replying, and reacting within a chat thread.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - ThreadMessageService
public final class ThreadMessageService {
    
    // MARK: - Shared Singleton
    public static let shared = ThreadMessageService()
    
    // MARK: - Private Properties
    private let db = FirebaseManager.shared.db
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Send Message
    public func sendMessage(
        threadID: String,
        text: String,
        imageURL: String? = nil,
        videoURL: String? = nil,
        replyTo: String? = nil
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            // MARK: Guest Logic
            if AuthManager.shared.isGuest {
                let docData: [String: Any] = [
                    "senderID": "Guest",
                    "senderName": "Guest",
                    "text": text,
                    "imageURL": imageURL ?? "",
                    "videoURL": videoURL ?? "",
                    "timestamp": Date(),
                    "reactions": [String: [String]](),
                    "replyTo": replyTo as Any
                ]
                db.collection("chatThreads")
                    .document(threadID)
                    .collection("messages")
                    .addDocument(data: docData) { _ in
                        ChatThreadService.shared.updateThreadLastUpdated(threadID: threadID)
                    }
            }
            return
        }
        
        let uid = currentUser.uid
        
        // MARK: Fetch User Name
        db.collection("users").document(uid).getDocument { snap, _ in
            let userData = snap?.data()
            let realName = userData?["name"] as? String ?? "User"
            
            let docData: [String: Any] = [
                "senderID": uid,
                "senderName": realName,
                "text": text,
                "imageURL": imageURL ?? "",
                "videoURL": videoURL ?? "",
                "timestamp": Date(),
                "reactions": [String: [String]](),
                "replyTo": replyTo as Any
            ]
            
            self.db.collection("chatThreads")
                .document(threadID)
                .collection("messages")
                .addDocument(data: docData) { _ in
                    ChatThreadService.shared.updateThreadLastUpdated(threadID: threadID)
                }
        }
    }
    
    // MARK: - Add Reaction
    public func addReaction(
        threadID: String,
        messageID: String,
        reaction: String
    ) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("chatThreads")
            .document(threadID)
            .collection("messages")
            .document(messageID)
        
        db.runTransaction({ transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(ref)
                guard var currentReactions = snapshot.data()?["reactions"] as? [String: [String]] else {
                    transaction.updateData([
                        "reactions": [reaction: [userID]]
                    ], forDocument: ref)
                    return nil
                }
                var userList = currentReactions[reaction] ?? []
                if !userList.contains(userID) {
                    userList.append(userID)
                }
                currentReactions[reaction] = userList
                transaction.updateData(["reactions": currentReactions], forDocument: ref)
            } catch {
                print("Error adding reaction: \(error.localizedDescription)")
            }
            return nil
        }, completion: { _, err in
            if let e = err {
                print("Transaction error (addReaction): \(e.localizedDescription)")
            }
        })
    }
    
    // MARK: - Remove Reaction
    public func removeReaction(
        threadID: String,
        messageID: String,
        reaction: String
    ) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("chatThreads")
            .document(threadID)
            .collection("messages")
            .document(messageID)
        
        db.runTransaction({ transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(ref)
                guard var currentReactions = snapshot.data()?["reactions"] as? [String: [String]] else {
                    return nil
                }
                guard var userList = currentReactions[reaction] else {
                    return nil
                }
                userList.removeAll(where: { $0 == userID })
                if userList.isEmpty {
                    currentReactions.removeValue(forKey: reaction)
                } else {
                    currentReactions[reaction] = userList
                }
                transaction.updateData(["reactions": currentReactions], forDocument: ref)
            } catch {
                print("Error removing reaction: \(error.localizedDescription)")
            }
            return nil
        }, completion: { _, err in
            if let e = err {
                print("Transaction error (removeReaction): \(e.localizedDescription)")
            }
        })
    }
}
