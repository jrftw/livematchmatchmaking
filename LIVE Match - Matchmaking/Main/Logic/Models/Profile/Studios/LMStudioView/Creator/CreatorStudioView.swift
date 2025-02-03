// MARK: CreatorStudioView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// Main screen for the Creator Section. The user can enable platforms and toggle “inAgency”
// to bring up a search-only agency flow. No creation from the Creator side.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorStudioView: View {
    @StateObject private var vm = CreatorStudioViewModel()
    
    @State private var selectedPlatformIndex: Int? = nil
    @State private var showingAgencySearch = false
    
    public init() {}
    
    public var body: some View {
        Form {
            Section("Creator: LIVE Platform Accounts") {
                ForEach(vm.platforms.indices, id: \.self) { i in
                    Toggle(isOn: $vm.platforms[i].enabled) {
                        Text(vm.platforms[i].name)
                    }
                    
                    if vm.platforms[i].enabled {
                        TextField("\(vm.platforms[i].name) Username", text: $vm.platforms[i].username)
                        TextField("\(vm.platforms[i].name) Profile", text: $vm.platforms[i].profileLink)
                        
                        // Toggle for Agency/Network
                        Toggle("Are you in an Agency / Network?", isOn: $vm.platforms[i].inAgency)
                        if vm.platforms[i].inAgency {
                            Button {
                                selectedPlatformIndex = i
                                showingAgencySearch = true
                            } label: {
                                // No "create" wording for the Creator side:
                                if vm.platforms[i].agencyName.isEmpty {
                                    Text("Search Agencies")
                                } else {
                                    Text("Agency: \(vm.platforms[i].agencyName)")
                                }
                            }
                        }
                    }
                }
            }
            
            Button("Save") {
                vm.saveToFirestore()
            }
        }
        .navigationTitle("Creator Section")
        .onAppear {
            vm.loadFromFirestore()
        }
        // Show the sheet for searching/joining an existing agency
        .sheet(isPresented: $showingAgencySearch) {
            // Pass inCreatorMode: true => no creation
            AgencySearchView(inCreatorMode: true) { chosenAgencyName in
                if let idx = selectedPlatformIndex {
                    vm.platforms[idx].agencyName = chosenAgencyName
                    // Optionally call vm.linkAgencyToUser(...) to store the doc ID in user doc
                }
            }
        }
    }
}
