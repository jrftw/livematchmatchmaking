//
//  ProfileTabWrapperView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/2/25.
//


//
//  ProfileTabWrapperView.swift
//  LIVE Match - Matchmaking
//
//  Ensures that when you tap “Profile,” you see *your* MyUserProfile instead of placeholders.
//  It fetches your user document from Firestore and then shows MyUserProfileView.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileTabWrapperView: View {
    
    // MARK: - State
    @State private var myProfile: MyUserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    // MARK: - Body
    public var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading your profile...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if let profile = myProfile {
                // Show the fully loaded profile
                MyUserProfileView(profile: profile)
            } else {
                // Fall back in case no profile was found
                Text("Profile not found.")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear(perform: loadProfile)
    }
    
    // MARK: - Load Profile
    private func loadProfile() {
        guard let currentUser = AuthManager.shared.user else {
            self.errorMessage = "No logged-in user."
            self.isLoading = false
            return
        }
        
        let userID = currentUser.uid
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).getDocument { docSnap, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            guard let data = docSnap?.data() else {
                self.errorMessage = "No profile data found."
                return
            }
            
            do {
                // Decode Firestore data into MyUserProfile
                let decoded = try Firestore.Decoder().decode(MyUserProfile.self, from: data)
                self.myProfile = decoded
            } catch {
                self.errorMessage = "Failed to decode profile: \(error.localizedDescription)"
            }
        }
    }
}