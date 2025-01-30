// MARK: File 14: ChatView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Simple community chat screen

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
                    let sender = data["sender"] as? String ?? ""
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
        
        if Auth.auth().currentUser == nil {
            if AuthManager.shared.isGuest {
                let docData: [String: Any] = [
                    "text": text,
                    "sender": "Guest",
                    "timestamp": Date()
                ]
                db.collection("messages").addDocument(data: docData) { error in
                    if let err = error {
                        print("Guest message error: \(err)")
                    }
                }
            }
            return
        }
        guard let user = Auth.auth().currentUser else { return }
        let docData: [String: Any] = [
            "text": text,
            "sender": user.uid,
            "timestamp": Date()
        ]
        db.collection("messages").addDocument(data: docData) { error in
            if let err = error {
                print("Error sending message: \(err)")
            }
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
                        VStack(alignment: .leading) {
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
