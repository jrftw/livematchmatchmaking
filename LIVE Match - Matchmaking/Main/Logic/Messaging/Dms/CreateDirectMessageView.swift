import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class DirectMessageUserSearchViewModel: ObservableObject {
    @Published var allUsers: [UserProfile] = []
    @Published var searchText = ""
    
    private let db = FirebaseManager.shared.db
    
    func fetchAllUsers() {
        db.collection("users").getDocuments { snap, err in
            if let err = err {
                print("Error fetching users: \(err.localizedDescription)")
                return
            }
            guard let docs = snap?.documents else { return }
            var loaded: [UserProfile] = []
            for doc in docs {
                if let user = try? doc.data(as: UserProfile.self) {
                    // Exclude the current user from results, if you prefer
                    if user.id != Auth.auth().currentUser?.uid {
                        loaded.append(user)
                    }
                }
            }
            DispatchQueue.main.async {
                self.allUsers = loaded
            }
        }
    }
    
    var filteredUsers: [UserProfile] {
        let trimmed = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return allUsers }
        return allUsers.filter {
            $0.username.lowercased().contains(trimmed)
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CreateDirectMessageView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = DirectMessageUserSearchViewModel()
    
    // We'll pass back the chosen userID via this completion
    let onPartnerSelected: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Search username...", text: $vm.searchText)
                
                List(vm.filteredUsers, id: \.id!) { user in
                    Button {
                        // user.id is optional, so forcibly unwrap with '!'
                        // or do guard let userID = user.id else { return }
                        let partnerID = user.id!
                        onPartnerSelected(partnerID)
                        
                        // Optionally create an initial DM doc now, or rely on the parent's side
                        
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text("@\(user.username)")
                                .font(.headline)
                            if let b = user.bio, !b.isEmpty {
                                Text(b).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New DM")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                vm.fetchAllUsers()
            }
        }
    }
}
