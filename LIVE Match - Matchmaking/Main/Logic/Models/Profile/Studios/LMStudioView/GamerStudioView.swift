//
//  GamerStudioView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: GamerStudioView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Lets a user specify a gamer username/profile link, and toggles for popular platforms.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct GamerStudioView: View {
    @StateObject private var vm = GamerStudioViewModel()
    
    var body: some View {
        Form {
            Section("Gamer Accounts") {
                TextField("New Gaming Username", text: $vm.newGamingUsername)
                TextField("Gaming Profile Link", text: $vm.newGamingProfileLink)
            }
            
            Section("Platforms") {
                Toggle("Xbox", isOn: $vm.xboxEnabled)
                Toggle("PSN", isOn: $vm.psnEnabled)
                Toggle("PC", isOn: $vm.pcEnabled)
                Toggle("Switch", isOn: $vm.switchEnabled)
                Toggle("Other", isOn: $vm.otherEnabled)
            }
            
            Button("Save") {
                vm.saveToFirestore()
            }
        }
        .navigationTitle("Gamer Section")
        .onAppear {
            vm.loadFromFirestore()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class GamerStudioViewModel: ObservableObject {
    @Published var newGamingUsername = ""
    @Published var newGamingProfileLink = ""
    @Published var xboxEnabled = false
    @Published var psnEnabled = false
    @Published var pcEnabled = false
    @Published var switchEnabled = false
    @Published var otherEnabled = false
    
    private let db = FirebaseManager.shared.db
    private var userID: String? { Auth.auth().currentUser?.uid }
    
    func loadFromFirestore() {
        guard let uid = userID else { return }
        db.collection("users").document(uid).getDocument { doc, error in
            guard let data = doc?.data(), error == nil else { return }
            
            self.newGamingUsername    = data["gamingUsername"] as? String ?? ""
            self.newGamingProfileLink = data["gamingProfileLink"] as? String ?? ""
            self.xboxEnabled          = data["xboxEnabled"] as? Bool ?? false
            self.psnEnabled           = data["psnEnabled"] as? Bool ?? false
            self.pcEnabled            = data["pcEnabled"] as? Bool ?? false
            self.switchEnabled        = data["switchEnabled"] as? Bool ?? false
            self.otherEnabled         = data["otherGamingEnabled"] as? Bool ?? false
        }
    }
    
    func saveToFirestore() {
        guard let uid = userID else { return }
        
        db.collection("users").document(uid).setData([
            "gamingUsername": newGamingUsername,
            "gamingProfileLink": newGamingProfileLink,
            "xboxEnabled": xboxEnabled,
            "psnEnabled": psnEnabled,
            "pcEnabled": pcEnabled,
            "switchEnabled": switchEnabled,
            "otherGamingEnabled": otherEnabled
        ], merge: true) { error in
            if let error = error {
                print("Error saving gamer data: \(error.localizedDescription)")
            } else {
                print("Gamer data saved.")
            }
        }
    }
}