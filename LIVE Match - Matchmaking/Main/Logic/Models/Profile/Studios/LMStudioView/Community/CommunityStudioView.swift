// MARK: CommunityStudioView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A screen showing the user's current community, plus a button to join/create.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CommunityStudioView: View {
    @StateObject private var vm = CommunityStudioViewModel()
    @State private var showingSearchSheet = false
    
    public init() {}
    
    public var body: some View {
        Form {
            Section("Current Community") {
                if vm.communityId.isEmpty {
                    Text("No community joined yet.")
                        .foregroundColor(.secondary)
                } else {
                    Text("Joined Community: \(vm.communityName)")
                    
                    if !vm.communityMission.isEmpty {
                        Text("Mission: \(vm.communityMission)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Button to pick or create a community
                Button("Join or Create Community") {
                    showingSearchSheet = true
                }
            }
            
            // Save changes to user's doc
            Button("Save") {
                vm.saveToFirestore()
            }
        }
        .navigationTitle("Community Section")
        .onAppear {
            vm.loadFromFirestore()
        }
        .sheet(isPresented: $showingSearchSheet) {
            CommunitySearchCreateView { chosenCommunity in
                // Update local state with chosen community details
                vm.communityId = chosenCommunity.id ?? ""
                vm.communityName = chosenCommunity.name
                vm.communityMission = chosenCommunity.mission
                vm.communityBannerURL = chosenCommunity.bannerURL ?? ""
                vm.communityProfilePicURL = chosenCommunity.profilePictureURL ?? ""
                vm.communityFounderId = chosenCommunity.founderId
                vm.communityFoundedDate = chosenCommunity.foundedDate
            }
        }
    }
}

// MARK: CommunityStudioViewModel.swift
// Loads & saves the user's community info under a "community" object in their user doc.

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class CommunityStudioViewModel: ObservableObject {
    @Published var communityId = ""
    @Published var communityName = ""
    @Published var communityMission = ""
    @Published var communityBannerURL = ""
    @Published var communityProfilePicURL = ""
    @Published var communityFounderId = ""
    @Published var communityFoundedDate = Date()
    
    private let db = FirebaseManager.shared.db
    private var userID: String? { Auth.auth().currentUser?.uid }
    
    public func loadFromFirestore() {
        guard let uid = userID else { return }
        
        db.collection("users").document(uid).getDocument { doc, error in
            guard let data = doc?.data(), error == nil else { return }
            
            // If 'community' dictionary is present, populate local fields
            if let com = data["community"] as? [String: Any] {
                self.communityId        = com["id"] as? String ?? ""
                self.communityName      = com["name"] as? String ?? ""
                self.communityMission   = com["mission"] as? String ?? ""
                self.communityBannerURL = com["bannerURL"] as? String ?? ""
                self.communityProfilePicURL = com["profilePictureURL"] as? String ?? ""
                self.communityFounderId = com["founderId"] as? String ?? ""
                
                if let ts = com["foundedDate"] as? Timestamp {
                    self.communityFoundedDate = ts.dateValue()
                }
            }
        }
    }
    
    public func saveToFirestore() {
        guard let uid = userID else { return }
        
        // Build dictionary for the 'community' field
        let communityDict: [String: Any] = [
            "id": communityId,
            "name": communityName,
            "mission": communityMission,
            "bannerURL": communityBannerURL,
            "profilePictureURL": communityProfilePicURL,
            "founderId": communityFounderId,
            "foundedDate": Timestamp(date: communityFoundedDate)
        ]
        
        // Save to user doc
        db.collection("users").document(uid).setData([
            "community": communityDict
        ], merge: true) { error in
            if let error = error {
                print("Error saving community data: \(error.localizedDescription)")
            } else {
                print("Community data saved successfully.")
            }
        }
    }
}
