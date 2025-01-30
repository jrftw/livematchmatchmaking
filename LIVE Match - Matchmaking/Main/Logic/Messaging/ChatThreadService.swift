//
//  ChatThreadService.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: ChatThreadService.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Handles creation and updates to chat threads.

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

public final class ChatThreadService {
    public static let shared = ChatThreadService()
    private let db = FirebaseManager.shared.db
    
    private init() {}
    
    // Creates a new chat thread (group or direct).
    // participants: array of user IDs
    // isGroup: whether it's a group
    // name: group name if isGroup == true
    public func createThread(participants: [String],
                             isGroup: Bool,
                             groupName: String? = nil,
                             completion: @escaping (String?) -> Void) {
        guard !participants.isEmpty else {
            completion(nil)
            return
        }
        let docRef = db.collection("chatThreads").document()
        let newThread = ChatThread(
            id: docRef.documentID,
            isGroup: isGroup,
            name: groupName,
            participants: participants,
            lastUpdated: Date()
        )
        do {
            try docRef.setData(from: newThread) { error in
                if let error = error {
                    print("Error creating thread: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(docRef.documentID)
                }
            }
        } catch {
            print("Error encoding thread: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    // Updates a thread's lastUpdated field when a new message arrives
    public func updateThreadLastUpdated(threadID: String) {
        db.collection("chatThreads").document(threadID).updateData([
            "lastUpdated": Date()
        ])
    }
}