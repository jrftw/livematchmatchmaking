//
//  AgencyCreatorNetworkStudioView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//
//  Shows user's Agencies/Networks. Tapping an agency navigates to AgencyDetailView
//  to see/edit details and view the roster of creators. Also displays in the list:
//  - Name
//  - Roster count
//  - Email
//  - Phone number

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AgencyCreatorNetworkStudioView: View {
    @StateObject private var vm = AgencyCreatorNetworkStudioViewModel()
    @State private var showingCreateForm = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if vm.agencies.isEmpty {
                    Text("No agencies or networks yet.")
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                } else {
                    List(vm.agencies) { agency in
                        NavigationLink(destination: AgencyDetailView(agency: agency)) {
                            VStack(alignment: .leading, spacing: 4) {
                                // Agency Name
                                Text(agency.name)
                                    .font(.headline)
                                
                                // Roster Count
                                let count = vm.rosterCounts[agency.id] ?? 0
                                Text("Roster: \(count)")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                
                                // Email
                                if !agency.email.isEmpty {
                                    Text("Email: \(agency.email)")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                                
                                // Phone
                                if !agency.phoneNumber.isEmpty {
                                    Text("Phone: \(agency.phoneNumber)")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
                
                Button("Create New Agency / Network") {
                    showingCreateForm = true
                }
                .font(.headline)
                .padding()
            }
            .navigationTitle("Agency / Creator Network")
            .onAppear {
                vm.loadUserAgencies()
            }
            .sheet(isPresented: $showingCreateForm) {
                AgencyCreateFormView(proposedName: "") { newName in
                    vm.addAgencyToUser(name: newName)
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

// MARK: AgencyCreatorNetworkStudioViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class AgencyCreatorNetworkStudioViewModel: ObservableObject {
    @Published var agencies: [Agency] = []
    
    // Store roster counts in a dictionary: [agencyId: Int]
    @Published var rosterCounts: [String: Int] = [:]
    
    private let db = FirebaseManager.shared.db
    private var uid: String? { Auth.auth().currentUser?.uid }
    
    func loadUserAgencies() {
        guard let userId = uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] doc, error in
            guard let self = self,
                  let data = doc?.data(),
                  error == nil else { return }
            
            if let arr = data["myAgencies"] as? [String], !arr.isEmpty {
                self.fetchAgencies(byIDs: arr)
            } else {
                // No agencies
                self.agencies = []
                self.rosterCounts = [:]
            }
        }
    }
    
    private func fetchAgencies(byIDs: [String]) {
        db.collection("agencies")
            .whereField(FieldPath.documentID(), in: byIDs)
            .getDocuments { [weak self] snap, err in
                guard let self = self,
                      let docs = snap?.documents,
                      err == nil else { return }
                
                // We'll fetch each doc => parse => also fetch roster count
                var tempAgencies: [Agency] = []
                var tempCounts: [String: Int] = [:]
                
                // We can do a DispatchGroup to update once all queries complete
                let group = DispatchGroup()
                
                for doc in docs {
                    let dict = doc.data()
                    let agency = Agency.fromDict(dict, docID: doc.documentID)
                    tempAgencies.append(agency)
                    
                    // Also fetch how many users have this ID in their myAgencies
                    group.enter()
                    self.db.collection("users")
                        .whereField("myAgencies", arrayContains: doc.documentID)
                        .getDocuments { snap2, err2 in
                            defer { group.leave() }
                            
                            guard let snap2 = snap2, err2 == nil else { return }
                            let count = snap2.documents.count
                            tempCounts[doc.documentID] = count
                        }
                }
                
                group.notify(queue: .main) {
                    // after all queries, assign
                    self.agencies = tempAgencies
                    self.rosterCounts = tempCounts
                }
            }
    }
    
    func addAgencyToUser(name: String) {
        guard let userId = uid else { return }
        
        db.collection("agencies")
            .whereField("name", isEqualTo: name)
            .limit(to: 1)
            .getDocuments { [weak self] snap, err in
                guard let self = self,
                      let doc = snap?.documents.first,
                      err == nil else { return }
                
                let agencyId = doc.documentID
                self.db.collection("users").document(userId)
                    .updateData([
                        "myAgencies": FieldValue.arrayUnion([agencyId])
                    ]) { error in
                        if let error = error {
                            print("Error linking agency: \(error.localizedDescription)")
                        } else {
                            print("Added agency ID \(agencyId) to user.")
                            self.loadUserAgencies()
                        }
                    }
            }
    }
}
