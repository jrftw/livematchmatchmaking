//
//  AgencyDetailView.swift
//  LIVE Match - Matchmaking
//
//  Displays details of a single Agency. If current user == ownerUID => can edit fields,
//  else read-only. Also shows "roster" of creators in that agency.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct AgencyDetailView: View {
    let agency: Agency
    
    @StateObject private var detailVM: AgencyDetailViewModel
    
    init(agency: Agency) {
        self.agency = agency
        _detailVM = StateObject(wrappedValue: AgencyDetailViewModel(agency: agency))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Form {
                Section("Agency Info") {
                    if detailVM.canEdit {
                        // SHOW TEXTFIELDS FOR OWNER
                        TextField("Name", text: $detailVM.agencyName)
                        TextField("Founders", text: $detailVM.founders)
                        TextField("Email", text: $detailVM.email)
                        TextField("Phone", text: $detailVM.phone)
                        TextField("Website", text: $detailVM.website)
                        TextField("Invite Link", text: $detailVM.inviteLink)
                        
                        TextEditor(text: $detailVM.bio)
                            .frame(minHeight: 80)
                        
                    } else {
                        // SHOW READ-ONLY FOR NON-OWNERS
                        Text("Name: \(detailVM.agencyName)")
                        Text("Founders: \(detailVM.founders)")
                        Text("Email: \(detailVM.email)")
                        Text("Phone: \(detailVM.phone)")
                        Text("Website: \(detailVM.website)")
                        Text("Invite Link: \(detailVM.inviteLink)")
                        
                        if !detailVM.bio.isEmpty {
                            Text("Bio:\n\(detailVM.bio)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Roster of Creators on LMM") {
                    if detailVM.roster.isEmpty {
                        Text("No creators found in this agency.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(detailVM.roster, id: \.self) { username in
                            Text(username)
                        }
                    }
                }
            }
            
            // Show the Save button only if canEdit
            if detailVM.canEdit {
                Button("Save Changes") {
                    detailVM.saveChanges()
                }
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Agency Details")
        .onAppear {
            detailVM.fetchAgency()
            detailVM.fetchRoster()
        }
    }
}

// MARK: - AgencyDetailViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class AgencyDetailViewModel: ObservableObject {
    private let agency: Agency
    private let db = FirebaseManager.shared.db
    
    // If current user’s UID == agency.ownerUID => canEdit = true
    @Published var canEdit: Bool = false
    
    // Agency fields
    @Published var agencyName: String = ""
    @Published var founders: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var website: String = ""
    @Published var inviteLink: String = ""
    @Published var bio: String = ""
    
    // The roster: a list of *username* values for all users who have this agency.
    @Published var roster: [String] = []
    
    init(agency: Agency) {
        self.agency = agency
        // Immediately set up some defaults
        self.agencyName = agency.name
        self.founders   = agency.founders
        self.email      = agency.email
        self.phone      = agency.phoneNumber
        // "ownerUID" is stored in `agency.ownerUID` for reference
        // We'll see if currentUser matches it:
        
        if let currentUID = Auth.auth().currentUser?.uid,
           currentUID == agency.ownerUID {
            self.canEdit = true
        } else {
            self.canEdit = false
        }
    }
    
    func fetchAgency() {
        // If you want to refresh the fields from Firestore, do so here:
        db.collection("agencies").document(agency.id).getDocument { [weak self] doc, err in
            guard let self = self,
                  let data = doc?.data(),
                  err == nil else { return }
            
            self.agencyName = data["name"] as? String ?? ""
            self.founders   = data["founders"] as? String ?? ""
            self.email      = data["email"] as? String ?? ""
            self.phone      = data["phoneNumber"] as? String ?? ""
            self.website    = data["website"] as? String ?? ""
            self.inviteLink = data["inviteLink"] as? String ?? ""
            self.bio        = data["bio"] as? String ?? ""
        }
    }
    
    func saveChanges() {
        let ref = db.collection("agencies").document(agency.id)
        ref.updateData([
            "name": agencyName,
            "founders": founders,
            "email": email,
            "phoneNumber": phone,
            "website": website,
            "inviteLink": inviteLink,
            "bio": bio
        ]) { err in
            if let err = err {
                print("Error updating agency: \(err.localizedDescription)")
            } else {
                print("Agency updated successfully.")
            }
        }
    }
    
    func fetchRoster() {
        db.collection("users")
            .whereField("myAgencies", arrayContains: agency.id)
            .getDocuments { [weak self] snap, err in
                guard let self = self,
                      let docs = snap?.documents,
                      err == nil else { return }
                
                let userNames: [String] = docs.compactMap { doc in
                    doc.data()["username"] as? String
                }
                
                self.roster = userNames
            }
    }
}
