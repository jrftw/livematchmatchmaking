// MARK: - DirectMessagesListView.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Model
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ChatPartner: Identifiable, Hashable {
    var id: String
    var username: String
}

// MARK: - ViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class DirectMessagesListViewModel: ObservableObject {
    @Published var recentChats: [ChatPartner] = []
    private let db = FirebaseManager.shared.db
    
    func fetchRecentChats() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        db.collection("dms")
            .whereField("fromUserID", isEqualTo: currentUser.uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self = self, let docs = snap?.documents else { return }
                
                let userIDs = docs.compactMap { $0.data()["toUserID"] as? String }
                let uniqueUserIDs = Array(Set(userIDs))
                
                var loadedChats: [ChatPartner] = []
                let group = DispatchGroup()
                
                for userID in uniqueUserIDs {
                    group.enter()
                    self.db.collection("users").document(userID).getDocument { docSnap, err in
                        defer { group.leave() }
                        guard err == nil, let doc = docSnap, doc.exists,
                              let data = doc.data(),
                              let username = data["username"] as? String
                        else { return }
                        
                        loadedChats.append(ChatPartner(id: userID, username: username))
                    }
                }
                
                group.notify(queue: .main) {
                    self.recentChats = loadedChats
                }
            }
    }
    
    func deleteChat(with partnerID: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let query = db.collection("dms")
            .whereField("fromUserID", isEqualTo: currentUser.uid)
            .whereField("toUserID", isEqualTo: partnerID)
        
        query.getDocuments { snap, err in
            if let err = err {
                print("Error fetching DM docs to delete: \(err.localizedDescription)")
                return
            }
            snap?.documents.forEach { doc in
                doc.reference.delete { delErr in
                    if let delErr = delErr {
                        print("Failed to delete doc: \(delErr.localizedDescription)")
                    }
                }
            }
        }
    }
}

// MARK: - View
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DirectMessagesListView: View {
    @StateObject private var vm = DirectMessagesListViewModel()
    @State private var showingNewDM = false
    
    var body: some View {
        List {
            ForEach(vm.recentChats) { partner in
                NavigationLink(destination: DirectMessageChatView(chatPartnerID: partner.id)) {
                    Text(partner.username)
                }
            }
            .onDelete { indexSet in
                for idx in indexSet {
                    let partner = vm.recentChats[idx]
                    vm.deleteChat(with: partner.id)
                }
                vm.recentChats.remove(atOffsets: indexSet)
            }
        }
        .navigationTitle("Direct Messages")
        .navigationBarItems(
            trailing: Button(action: {
                showingNewDM = true
            }) {
                Image(systemName: "plus")
            }
        )
        .onAppear {
            vm.fetchRecentChats()
        }
        .sheet(isPresented: $showingNewDM) {
            CreateDirectMessageView { partnerID in
                if !vm.recentChats.contains(where: { $0.id == partnerID }) {
                    vm.recentChats.append(ChatPartner(id: partnerID, username: partnerID))
                }
            }
        }
    }
}
