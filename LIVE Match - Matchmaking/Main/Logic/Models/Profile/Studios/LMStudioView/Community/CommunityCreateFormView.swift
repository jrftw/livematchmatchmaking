//
//  CommunityCreateFormView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: CommunityCreateFormView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// A sub-form that creates a new community with name, mission, etc.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CommunityCreateFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var mission: String = ""
    @State private var founderId: String = ""
    @State private var profilePictureURL: String = ""
    @State private var bannerURL: String = ""
    
    private let db = FirebaseManager.shared.db
    
    let onCreated: (Community) -> Void
    
    public init(
        proposedName: String,
        onCreated: @escaping (Community) -> Void
    ) {
        _name = State(initialValue: proposedName)
        self.onCreated = onCreated
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Create Community") {
                    TextField("Community Name", text: $name)
                    TextField("Mission", text: $mission)
                    TextField("Profile Picture URL", text: $profilePictureURL)
                    TextField("Banner URL", text: $bannerURL)
                }
                
                Button("Create") {
                    createCommunity()
                }
            }
            .navigationTitle("New Community")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let uid = Auth.auth().currentUser?.uid {
                    self.founderId = uid
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private func createCommunity() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let newDoc = db.collection("communities").document()
        let docId = newDoc.documentID
        
        let newCom = Community(
            id: docId,
            name: trimmedName,
            mission: mission,
            founderId: founderId,
            foundedDate: Date(),
            profilePictureURL: profilePictureURL.isEmpty ? nil : profilePictureURL,
            bannerURL: bannerURL.isEmpty ? nil : bannerURL
        )
        
        newDoc.setData(newCom.asDictionary()) { err in
            if let err = err {
                print("Error creating new community: \(err.localizedDescription)")
            } else {
                print("Community created: \(newCom.name)")
                onCreated(newCom)
                dismiss()
            }
        }
    }
}