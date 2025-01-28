// MARK: File 20: ProfileView.swift
// MARK: Example form-based editor for a "profile" collection in Firestore

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ProfileView: View {
    @State private var profileType: String = "Creator"
    @State private var bio: String = ""
    @State private var socialMedia: String = ""
    @State private var gamingAccounts: String = ""
    
    var body: some View {
        Form {
            Picker("Profile Type", selection: $profileType) {
                Text("Creator").tag("Creator")
                Text("Agency").tag("Agency")
                Text("Team").tag("Team")
            }
            TextField("Bio", text: $bio)
            TextField("Social Media Links", text: $socialMedia)
            TextField("Gaming Accounts", text: $gamingAccounts)
            Button("Save Profile") {
                saveProfile()
            }
        }
        .navigationTitle("Profile")
    }
    
    func saveProfile() {
        let profileData: [String: Any] = [
            "type": profileType,
            "bio": bio,
            "socialMedia": socialMedia,
            "gamingAccounts": gamingAccounts
        ]
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("profiles").document(uid).setData(profileData) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile saved successfully!")
            }
        }
    }
}
