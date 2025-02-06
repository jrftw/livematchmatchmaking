// MARK: - CreateDirectMessageView.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
        return allUsers.filter { $0.username.lowercased().contains(trimmed) }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CreateDirectMessageView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = DirectMessageUserSearchViewModel()
    
    let onPartnerSelected: (String) -> Void
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            content
                .navigationTitle("New DM")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .onAppear {
                    vm.fetchAllUsers()
                }
        }
        #else
        VStack {
            Text("New DM")
                .font(.title)
                .padding(.top, 10)
            content
            HStack {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            vm.fetchAllUsers()
        }
        #endif
    }
    
    @ViewBuilder
    private var content: some View {
        Form {
            TextField("Search username...", text: $vm.searchText)
            
            List(vm.filteredUsers, id: \.id!) { user in
                Button {
                    let partnerID = user.id!
                    onPartnerSelected(partnerID)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text("@\(user.username)")
                            .font(.headline)
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}
