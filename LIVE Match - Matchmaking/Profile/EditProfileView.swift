//
//  EditProfileView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: EditProfileView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows the current user to edit all fields in their profile, including new 12-hour time slot availability.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var profile: UserProfile
    
    @State private var newName: String = ""
    @State private var newBio: String = ""
    @State private var newPhone: String = ""
    @State private var newClanTag: String = ""
    
    @State private var newSocialLinks: [String] = []
    @State private var newSocialLink = ""
    
    @State private var newGamingAccounts: [String] = []
    @State private var newGamingAccount = ""
    
    @State private var newLivePlatforms: [String] = []
    @State private var newLivePlatform = ""
    
    // This Set<String> stores 12-hour time slots the user is available for (e.g., "2:15 PM").
    @State private var timeSlots: Set<String> = []
    @State private var showTimeSlots = false
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Display Name", text: $newName)
            }
            Section(header: Text("Bio")) {
                TextField("Bio", text: $newBio)
            }
            Section(header: Text("Phone")) {
                TextField("Phone Number", text: $newPhone)
            }
            Section(header: Text("Clan Tag")) {
                TextField("Clan Tag", text: $newClanTag)
            }
            
            Section(header: Text("Social Links")) {
                ForEach(newSocialLinks, id: \.self) { link in
                    Text(link)
                }
                HStack {
                    TextField("Add Social Link", text: $newSocialLink)
                    Button("Add") {
                        guard !newSocialLink.isEmpty else { return }
                        newSocialLinks.append(newSocialLink)
                        newSocialLink = ""
                    }
                }
            }
            
            Section(header: Text("Gaming Accounts")) {
                ForEach(newGamingAccounts, id: \.self) { account in
                    Text(account)
                }
                HStack {
                    TextField("Add Gaming Account", text: $newGamingAccount)
                    Button("Add") {
                        guard !newGamingAccount.isEmpty else { return }
                        newGamingAccounts.append(newGamingAccount)
                        newGamingAccount = ""
                    }
                }
            }
            
            Section(header: Text("Live Platforms")) {
                ForEach(newLivePlatforms, id: \.self) { platform in
                    Text(platform)
                }
                HStack {
                    TextField("Add Live Platform", text: $newLivePlatform)
                    Button("Add") {
                        guard !newLivePlatform.isEmpty else { return }
                        newLivePlatforms.append(newLivePlatform)
                        newLivePlatform = ""
                    }
                }
            }
            
            // A button that opens a sheet to select times in 12-hour format with 15-min increments.
            Section(header: Text("Availability Times")) {
                Button("Edit Time Slots (\(timeSlots.count) selected)") {
                    showTimeSlots = true
                }
            }
            
            Button("Save") {
                saveChanges()
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            newName = profile.name
            newBio = profile.bio
            newPhone = profile.phone ?? ""
            newClanTag = profile.clanTag ?? ""
            newSocialLinks = profile.socialLinks
            newGamingAccounts = profile.gamingAccounts
            newLivePlatforms = profile.livePlatforms
            
            // If your UserProfile has a property for time slots, load it:
            // timeSlots = profile.timeSlotAvailability ?? []
        }
        .sheet(isPresented: $showTimeSlots) {
            NavigationView {
                TimeAvailabilityView(selectedTimeSlots: $timeSlots)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showTimeSlots = false
                            }
                        }
                    }
            }
        }
    }
    
    private func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid, uid == profile.id else {
            print("Not authorized to edit this profile.")
            return
        }
        
        let db = FirebaseManager.shared.db
        
        var updated = profile
        updated.name = newName
        updated.bio = newBio
        updated.phone = newPhone.isEmpty ? nil : newPhone
        updated.clanTag = newClanTag.isEmpty ? nil : newClanTag
        updated.socialLinks = newSocialLinks
        updated.gamingAccounts = newGamingAccounts
        updated.livePlatforms = newLivePlatforms
        
        // If you stored time slot data in your UserProfile, assign it here:
        // updated.timeSlotAvailability = Array(timeSlots)
        
        do {
            try db.collection("users")
                .document(uid)
                .setData(from: updated)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error updating profile: \(error.localizedDescription)")
        }
    }
}
