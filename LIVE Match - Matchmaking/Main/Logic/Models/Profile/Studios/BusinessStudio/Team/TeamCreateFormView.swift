//
//  TeamCreateFormView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: TeamCreateFormView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// A form to create a new Team doc in "teams" collection, then link it to the user.

import SwiftUI
import Firebase

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TeamCreateFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var teamName: String = ""
    @State private var username: String = ""
    @State private var foundingDate: Date = Date()
    @State private var founders: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var website: String = ""
    
    @State private var bannerURL: String = ""
    @State private var profilePicURL: String = ""
    
    private let db = FirebaseManager.shared.db
    
    /// Called with a `Team` object after creation
    let onCreated: (Team) -> Void
    
    public init(onCreated: @escaping (Team) -> Void) {
        self.onCreated = onCreated
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Create a Team") {
                    TextField("Team Name", text: $teamName)
                    TextField("Team Username", text: $username)
                    DatePicker("Founding Date", selection: $foundingDate, displayedComponents: .date)
                    TextField("Founders (comma-separated)", text: $founders)
                    TextField("Email (if applicable)", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number (if applicable)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Website (if applicable)", text: $website)
                        .keyboardType(.URL)
                }
                
                Section("Team Assets") {
                    TextField("Banner URL", text: $bannerURL)
                        .keyboardType(.URL)
                    TextField("Profile Picture URL", text: $profilePicURL)
                        .keyboardType(.URL)
                }
                
                Button("Create Team") {
                    createTeam()
                }
                .disabled(teamName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("New Team")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private func createTeam() {
        let trimmedName = teamName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Create a doc in "teams" collection
        let ref = db.collection("teams").document()
        let docID = ref.documentID
        
        let newTeam = Team(
            id: docID,
            name: trimmedName,
            username: username.trimmingCharacters(in: .whitespaces),
            foundingDate: foundingDate,
            founders: founders,
            email: email,
            phoneNumber: phoneNumber,
            website: website,
            bannerURL: bannerURL.isEmpty ? nil : bannerURL,
            profilePictureURL: profilePicURL.isEmpty ? nil : profilePicURL
        )
        
        ref.setData(newTeam.asDictionary()) { err in
            if let err = err {
                print("Error creating team: \(err.localizedDescription)")
            } else {
                // Return the newly created team object
                onCreated(newTeam)
                dismiss()
            }
        }
    }
}