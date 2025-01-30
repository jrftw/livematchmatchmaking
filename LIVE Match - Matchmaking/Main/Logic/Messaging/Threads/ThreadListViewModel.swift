//
//  ThreadListViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: ThreadListViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Shows user's chat threads, sorted by lastUpdated.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ThreadListViewModel: ObservableObject {
    @Published public var threads: [ChatThread] = []
    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?
    
    public init() {}
    
    public func startListening() {
        guard let user = Auth.auth().currentUser else {
            if AuthManager.shared.isGuest { // Show no threads or a guest thread
                threads = []
            }
            return
        }
        // Only threads containing the user's ID in participants
        listener = db.collection("chatThreads")
            .whereField("participants", arrayContains: user.uid)
            .order(by: "lastUpdated", descending: true)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self else { return }
                guard let docs = snap?.documents else { return }
                self.threads = docs.compactMap {
                    try? $0.data(as: ChatThread.self)
                }
            }
    }
    
    public func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}