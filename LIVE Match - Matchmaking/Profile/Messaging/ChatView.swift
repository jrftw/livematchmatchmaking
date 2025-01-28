// MARK: File 14: ChatView.swift
// MARK: Simple community chat screen

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ChatView: View {
    @StateObject private var vm = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.messages, id: \.id) { msg in
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

// MARK: ChatViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private let db = FirebaseManager.shared.db
    
    func fetchMessages() {
        db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snap, _ in
                guard let docs = snap?.documents else { return }
                self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
            }
    }
    
    func sendMessage(text: String) {
        guard let user = Auth.auth().currentUser else {
            if AuthManager.shared.isGuest {
                let newMsg = ChatMessage(
                    id: nil,
                    text: text,
                    sender: "Guest",
                    timestamp: Date()
                )
                do {
                    try db.collection("messages").addDocument(from: newMsg)
                } catch {
                    print("Guest message error: \(error)")
                }
            }
            return
        }
        let newMsg = ChatMessage(
            id: nil,
            text: text,
            sender: user.uid,
            timestamp: Date()
        )
        do {
            try db.collection("messages").addDocument(from: newMsg)
        } catch {
            print("Error sending message: \(error)")
        }
    }
}
