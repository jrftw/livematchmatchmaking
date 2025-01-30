//
//  ThreadViewModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: ThreadViewModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Observes messages within a single thread.

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ThreadViewModel: ObservableObject {
    @Published public var messages: [ThreadMessage] = []
    private let db = FirebaseManager.shared.db
    
    private var listener: ListenerRegistration?
    
    public init() {}
    
    public func startListening(threadID: String) {
        stopListening()
        listener = db.collection("chatThreads")
            .document(threadID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self else { return }
                guard let docs = snap?.documents else { return }
                self.messages = docs.compactMap { doc in
                    try? doc.data(as: ThreadMessage.self)
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