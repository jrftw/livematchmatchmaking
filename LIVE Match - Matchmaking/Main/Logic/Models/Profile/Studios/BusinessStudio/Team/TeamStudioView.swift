//
//  TeamStudioView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: TeamStudioView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// Allows the user to manage or create a Team. If they own a team, show it; otherwise let them create.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TeamStudioView: View {
    @StateObject private var vm = TeamStudioViewModel()
    @State private var showingCreateForm = false
    
    var body: some View {
        VStack(spacing: 16) {
            if vm.teamId.isEmpty {
                // No team joined/owned: show a placeholder
                Text("You have no team yet.")
                    .foregroundColor(.secondary)
                
                Button("Create a Team") {
                    showingCreateForm = true
                }
            } else {
                // If the user owns or joined a team, display minimal info
                Text("Team Name: \(vm.teamName)")
                    .font(.headline)
                if !vm.teamFounders.isEmpty {
                    Text("Founders: \(vm.teamFounders)")
                        .font(.subheadline)
                }
                if !vm.teamEmail.isEmpty {
                    Text("Contact Email: \(vm.teamEmail)")
                        .font(.footnote)
                }
                // etc. Display or manage more properties...
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Team Section")
        .onAppear {
            vm.loadTeamFromFirestore()
        }
        .sheet(isPresented: $showingCreateForm) {
            TeamCreateFormView { createdTeam in
                // Once the user creates a team, store it locally
                vm.teamId = createdTeam.id ?? ""
                vm.teamName = createdTeam.name
                vm.teamUsername = createdTeam.username
                vm.foundingDate = createdTeam.foundingDate
                vm.teamFounders = createdTeam.founders
                vm.teamEmail = createdTeam.email
                vm.teamPhoneNumber = createdTeam.phoneNumber
                vm.teamWebsite = createdTeam.website
                vm.bannerURL = createdTeam.bannerURL ?? ""
                vm.profilePicURL = createdTeam.profilePictureURL ?? ""
                
                // Then save it in the user doc
                vm.saveTeamToFirestore()
            }
        }
    }
}

// MARK: TeamStudioViewModel.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// Loads & saves a user's Team info from Firestore (like "team" field in their doc).

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class TeamStudioViewModel: ObservableObject {
    @Published var teamId: String = ""
    @Published var teamName: String = ""
    @Published var teamUsername: String = ""
    @Published var foundingDate: Date = Date()
    @Published var teamFounders: String = ""
    @Published var teamEmail: String = ""
    @Published var teamPhoneNumber: String = ""
    @Published var teamWebsite: String = ""
    @Published var bannerURL: String = ""
    @Published var profilePicURL: String = ""
    
    private let db = FirebaseManager.shared.db
    private var uid: String? { Auth.auth().currentUser?.uid }
    
    func loadTeamFromFirestore() {
        guard let userId = uid else { return }
        db.collection("users").document(userId).getDocument { doc, error in
            guard let data = doc?.data(), error == nil else { return }
            
            if let teamDict = data["team"] as? [String: Any] {
                self.teamId       = teamDict["id"] as? String ?? ""
                self.teamName     = teamDict["name"] as? String ?? ""
                self.teamUsername = teamDict["username"] as? String ?? ""
                if let ts = teamDict["foundingDate"] as? Timestamp {
                    self.foundingDate = ts.dateValue()
                }
                self.teamFounders    = teamDict["founders"] as? String ?? ""
                self.teamEmail       = teamDict["email"] as? String ?? ""
                self.teamPhoneNumber = teamDict["phoneNumber"] as? String ?? ""
                self.teamWebsite     = teamDict["website"] as? String ?? ""
                self.bannerURL       = teamDict["bannerURL"] as? String ?? ""
                self.profilePicURL   = teamDict["profilePictureURL"] as? String ?? ""
            }
        }
    }
    
    func saveTeamToFirestore() {
        guard let userId = uid else { return }
        
        let teamDict: [String: Any] = [
            "id": teamId,
            "name": teamName,
            "username": teamUsername,
            "foundingDate": Timestamp(date: foundingDate),
            "founders": teamFounders,
            "email": teamEmail,
            "phoneNumber": teamPhoneNumber,
            "website": teamWebsite,
            "bannerURL": bannerURL,
            "profilePictureURL": profilePicURL
        ]
        
        db.collection("users").document(userId).setData([
            "team": teamDict
        ], merge: true) { err in
            if let err = err {
                print("Error saving team: \(err.localizedDescription)")
            } else {
                print("Team saved successfully.")
            }
        }
    }
}