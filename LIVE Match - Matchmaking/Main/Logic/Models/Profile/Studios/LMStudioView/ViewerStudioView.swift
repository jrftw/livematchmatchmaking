//
//  ViewerStudioView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: ViewerStudioView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Allows a user to enable specific viewer platforms, input username/link, favorite creators.
// Saves data under "viewerPlatforms" in the user doc.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ViewerStudioView: View {
    @StateObject private var vm = ViewerStudioViewModel()
    
    var body: some View {
        Form {
            Section("LIVE Platform Accounts (Viewer)") {
                ForEach(vm.platforms.indices, id: \.self) { i in
                    Toggle(isOn: $vm.platforms[i].enabled) {
                        Text(vm.platforms[i].name)
                    }
                    
                    if vm.platforms[i].enabled {
                        TextField("\(vm.platforms[i].name) Username", text: $vm.platforms[i].username)
                        TextField("\(vm.platforms[i].name) Profile Link", text: $vm.platforms[i].profileLink)
                        TextField("Favorite Creators", text: $vm.platforms[i].favoriteCreators)
                    }
                }
            }
            
            Button("Save") {
                vm.saveToFirestore()
            }
        }
        .navigationTitle("Viewer Section")
        .onAppear {
            vm.loadFromFirestore()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class ViewerStudioViewModel: ObservableObject {
    @Published var platforms: [ViewerPlatform] = [
        .init(name: "TikTok"),
        .init(name: "Favorited"),
        .init(name: "Mango"),
        .init(name: "LIVE.ME"),
        .init(name: "YouNow"),
        .init(name: "YouTube"),
        .init(name: "Clapper"),
        .init(name: "Fanbase"),
        .init(name: "Kick"),
        .init(name: "Other")
    ]
    
    private let db = FirebaseManager.shared.db
    private var userID: String? { Auth.auth().currentUser?.uid }
    
    func loadFromFirestore() {
        guard let uid = userID else { return }
        db.collection("users").document(uid).getDocument { doc, error in
            guard let data = doc?.data(), error == nil else { return }
            
            if let stored = data["viewerPlatforms"] as? [[String: Any]] {
                for i in stored.indices {
                    if i < self.platforms.count {
                        let dict = stored[i]
                        self.platforms[i].enabled = dict["enabled"] as? Bool ?? false
                        self.platforms[i].username = dict["username"] as? String ?? ""
                        self.platforms[i].profileLink = dict["profileLink"] as? String ?? ""
                        self.platforms[i].favoriteCreators = dict["favoriteCreators"] as? String ?? ""
                    }
                }
            }
        }
    }
    
    func saveToFirestore() {
        guard let uid = userID else { return }
        let mapped = platforms.map { $0.asDictionary() }
        
        db.collection("users").document(uid).setData([
            "viewerPlatforms": mapped
        ], merge: true) { error in
            if let error = error {
                print("Error saving viewer platforms: \(error.localizedDescription)")
            } else {
                print("Viewer platforms saved.")
            }
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ViewerPlatform: Codable {
    var name: String
    var enabled: Bool = false
    var username: String = ""
    var profileLink: String = ""
    var favoriteCreators: String = ""
    
    func asDictionary() -> [String: Any] {
        [
            "name": name,
            "enabled": enabled,
            "username": username,
            "profileLink": profileLink,
            "favoriteCreators": favoriteCreators
        ]
    }
}