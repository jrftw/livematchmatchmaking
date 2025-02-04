import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class DirectMessagesListViewModel: ObservableObject {
    @Published var recentChats: [String] = []
    private let db = FirebaseManager.shared.db
    
    func fetchRecentChats() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Listen for DMs where the current user is the "fromUserID"
        db.collection("dms")
            .whereField("fromUserID", isEqualTo: currentUser.uid)
            .addSnapshotListener { snap, _ in
                guard let docs = snap?.documents else { return }
                
                let userIDs = docs.compactMap { $0.data()["toUserID"] as? String }
                
                // Also, if you want to see DMs where the user is "toUserID",
                // you'd do a separate query or a different approach.
                // Or you can unify them with .whereField("fromUserID", in: [currentUser.uid, ...]) if you want two-sided listing.
                
                // For now, just store unique userIDs
                self.recentChats = Array(Set(userIDs))
            }
    }
    
    // Example: remove the DM documents in Firestore for that user
    // or just remove from the local array if you prefer.
    func deleteChat(with partnerID: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // This example removes *all* DM docs where fromUser = currentUser
        // and toUser = partnerID. Adjust if you also want to remove docs
        // where fromUser = partnerID, toUser = currentUser, etc.
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

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DirectMessagesListView: View {
    @StateObject private var vm = DirectMessagesListViewModel()
    @State private var showingNewDM = false
    
    var body: some View {
        List {
            ForEach(vm.recentChats, id: \.self) { userID in
                NavigationLink(destination: DirectMessageChatView(chatPartnerID: userID)) {
                    Text("Chat with: \(userID)")
                }
            }
            .onDelete { indexSet in
                // Remove from local array, optionally also from Firestore
                for idx in indexSet {
                    let partnerID = vm.recentChats[idx]
                    vm.deleteChat(with: partnerID) // optional
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
                // After user picks a partner, you can either:
                // - Force immediate navigation to that DM
                // - Just do nothing and let them see it in the list next time
                // For example, you can manually add it to the list:
                if !vm.recentChats.contains(partnerID) {
                    vm.recentChats.append(partnerID)
                }
            }
        }
    }
}
