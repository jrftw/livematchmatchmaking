// MARK: - DirectMessageChatView.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct DirectMessage: Identifiable {
    public var id: String
    public var fromUserID: String
    public var toUserID: String
    public var text: String
    public var timestamp: Date
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class DirectMessageChatViewModel: ObservableObject {
    @Published var dms: [DirectMessage] = []
    @Published var chatPartnerUsername: String = ""
    
    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?
    
    func startListening(chatPartnerID: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let query = db.collection("dms")
            .whereField("fromUserID", in: [currentUser.uid, chatPartnerID])
            .whereField("toUserID", in: [currentUser.uid, chatPartnerID])
            .order(by: "timestamp", descending: false)
        
        listener = query.addSnapshotListener { snap, _ in
            guard let docs = snap?.documents else { return }
            var loaded: [DirectMessage] = []
            for doc in docs {
                let data = doc.data()
                let docID = doc.documentID
                let fromID = data["fromUserID"] as? String ?? ""
                let toID = data["toUserID"] as? String ?? ""
                let text = data["text"] as? String ?? ""
                let ts = data["timestamp"] as? Timestamp
                let timestamp = ts?.dateValue() ?? Date()
                
                loaded.append(
                    DirectMessage(
                        id: docID,
                        fromUserID: fromID,
                        toUserID: toID,
                        text: text,
                        timestamp: timestamp
                    )
                )
            }
            self.dms = loaded
        }
    }
    
    func fetchChatPartnerUsername(_ partnerID: String) {
        db.collection("users").document(partnerID).getDocument { doc, error in
            guard error == nil, let data = doc?.data(),
                  let username = data["username"] as? String else { return }
            DispatchQueue.main.async {
                self.chatPartnerUsername = username
            }
        }
    }
    
    func sendDM(to partnerID: String, text: String) {
        guard !text.isEmpty else { return }
        if Auth.auth().currentUser == nil {
            if AuthManager.shared.isGuest {
                let docData: [String: Any] = [
                    "fromUserID": "Guest",
                    "toUserID": partnerID,
                    "text": text,
                    "timestamp": Date()
                ]
                db.collection("dms").addDocument(data: docData) { error in
                    if let err = error {
                        print("Guest DM error: \(err)")
                    }
                }
            }
            return
        }
        guard let currentUser = Auth.auth().currentUser else { return }
        let docData: [String: Any] = [
            "fromUserID": currentUser.uid,
            "toUserID": partnerID,
            "text": text,
            "timestamp": Date()
        ]
        db.collection("dms").addDocument(data: docData) { error in
            if let err = error {
                print("Error sending DM: \(err)")
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DirectMessageChatView: View {
    let chatPartnerID: String
    @StateObject private var vm = DirectMessageChatViewModel()
    @State private var text = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(vm.dms) { dm in
                        let isCurrentUser = dm.fromUserID == Auth.auth().currentUser?.uid
                        let bgColor = isCurrentUser ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2)
                        HStack {
                            if isCurrentUser { Spacer() }
                            Text(dm.text)
                                .padding()
                                .background(bgColor)
                                .cornerRadius(8)
                            if !isCurrentUser { Spacer() }
                        }
                    }
                }
                .padding(.top)
            }
            HStack {
                TextField("Message...", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    vm.sendDM(to: chatPartnerID, text: text)
                    text = ""
                }
            }
            .padding()
        }
        .navigationTitle(
            vm.chatPartnerUsername.isEmpty
            ? "DM with \(chatPartnerID)"
            : "DM with \(vm.chatPartnerUsername)"
        )
        .onAppear {
            vm.startListening(chatPartnerID: chatPartnerID)
            vm.fetchChatPartnerUsername(chatPartnerID)
        }
    }
}
