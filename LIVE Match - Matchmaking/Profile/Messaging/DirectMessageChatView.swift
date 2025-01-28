// MARK: File 13: DirectMessageChatView.swift
// MARK: One-on-one chat screen

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DirectMessageChatView: View {
    let chatPartnerID: String
    @StateObject private var vm = DirectMessageChatViewModel()
    @State private var text = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(vm.dms) { dm in
                    VStack(alignment: dm.fromUserID == Auth.auth().currentUser?.uid ? .trailing : .leading) {
                        Text(dm.text)
                            .padding()
                            .background(dm.fromUserID == Auth.auth().currentUser?.uid ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: dm.fromUserID == Auth.auth().currentUser?.uid ? .trailing : .leading)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            
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
        .navigationTitle("DM with \(chatPartnerID)")
        .onAppear {
            vm.startListening(chatPartnerID: chatPartnerID)
        }
    }
}

// MARK: DirectMessageChatViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class DirectMessageChatViewModel: ObservableObject {
    @Published var dms: [DirectMessage] = []
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
            self.dms = docs.compactMap { try? $0.data(as: DirectMessage.self) }
        }
    }
    
    func sendDM(to partnerID: String, text: String) {
        guard let currentUser = Auth.auth().currentUser else {
            if AuthManager.shared.isGuest {
                let dm = DirectMessage(
                    id: nil,
                    fromUserID: "Guest",
                    toUserID: partnerID,
                    text: text,
                    timestamp: Date()
                )
                do {
                    try db.collection("dms").addDocument(from: dm)
                } catch {
                    print("Guest DM error: \(error)")
                }
            }
            return
        }
        let dm = DirectMessage(
            id: nil,
            fromUserID: currentUser.uid,
            toUserID: partnerID,
            text: text,
            timestamp: Date()
        )
        do {
            try db.collection("dms").addDocument(from: dm)
        } catch {
            print("Error sending DM: \(error)")
        }
    }
    
    deinit {
        listener?.remove()
    }
}
