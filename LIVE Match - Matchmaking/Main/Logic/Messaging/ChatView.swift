//
//  ChatView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Community chat screen that now stores and displays the user's actual username
//  instead of just their user ID.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct ChatMessage: Identifiable {
    public var id: String
    public var text: String
    public var sender: String
    public var timestamp: Date
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private let db = FirebaseManager.shared.db
    
    func fetchMessages() {
        db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snap, _ in
                guard let docs = snap?.documents else { return }
                var loaded: [ChatMessage] = []
                for document in docs {
                    let data = document.data()
                    let docID = document.documentID
                    let text = data["text"] as? String ?? ""
                    let sender = data["sender"] as? String ?? "Unknown"
                    let ts = data["timestamp"] as? Timestamp
                    let timestamp = ts?.dateValue() ?? Date()
                    
                    let msg = ChatMessage(
                        id: docID,
                        text: text,
                        sender: sender,
                        timestamp: timestamp
                    )
                    loaded.append(msg)
                }
                self.messages = loaded
            }
    }
    
    func sendMessage(text: String) {
        guard !text.isEmpty else { return }
        
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            db.collection("users").document(uid).getDocument { snap, _ in
                let userData = snap?.data() ?? [:]
                let username = userData["username"] as? String ?? uid
                let docData: [String: Any] = [
                    "text": text,
                    "sender": username,
                    "timestamp": Date()
                ]
                self.db.collection("messages").addDocument(data: docData)
            }
        } else if AuthManager.shared.isGuest {
            let docData: [String: Any] = [
                "text": text,
                "sender": "Guest",
                "timestamp": Date()
            ]
            db.collection("messages").addDocument(data: docData)
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ChatView: View {
    @StateObject private var vm = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.messages) { msg in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(msg.sender)
                                .font(.caption)
                            Text(msg.text)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            
            HStack {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    vm.sendMessage(text: messageText)
                    messageText = ""
                }
            }
            .padding()
        }
        .navigationTitle("Community Chat")
        .onAppear {
            vm.fetchMessages()
        }
    }
}
