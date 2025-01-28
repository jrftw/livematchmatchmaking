// MARK: File 12: DirectMessagesListView.swift
// MARK: Shows list of direct message threads

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DirectMessagesListView: View {
    @StateObject private var vm = DirectMessagesListViewModel()
    
    var body: some View {
        List(vm.recentChats, id: \.self) { userID in
            NavigationLink(destination: DirectMessageChatView(chatPartnerID: userID)) {
                Text("Chat with: \(userID)")
            }
        }
        .navigationTitle("Direct Messages")
        .onAppear {
            vm.fetchRecentChats()
        }
    }
}

// MARK: DirectMessagesListViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class DirectMessagesListViewModel: ObservableObject {
    @Published var recentChats: [String] = []
    private let db = FirebaseManager.shared.db
    
    func fetchRecentChats() {
        guard let currentUser = Auth.auth().currentUser else { return }
        db.collection("dms")
            .whereField("fromUserID", isEqualTo: currentUser.uid)
            .addSnapshotListener { snap, _ in
                guard let docs = snap?.documents else { return }
                let userIDs = docs.compactMap { $0["toUserID"] as? String }
                self.recentChats = Array(Set(userIDs))
            }
    }
}
