//
//  CommunitySearchCreateView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: CommunitySearchCreateView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// Lets the user search existing communities or create a new one.

import SwiftUI
import Firebase

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CommunitySearchCreateView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = CommunitySearchCreateViewModel()
    let onSelectCommunity: (Community) -> Void
    
    public init(onSelectCommunity: @escaping (Community) -> Void) {
        self.onSelectCommunity = onSelectCommunity
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                TextField("Search community name...", text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                List {
                    if vm.showCreateRow {
                        Section("Create New Community") {
                            Button("Create \"\(vm.searchQuery)\"") {
                                vm.showCreateForm = true
                            }
                        }
                    }
                    
                    Section("Existing Communities") {
                        ForEach(vm.filteredResults) { com in
                            Button {
                                onSelectCommunity(com)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(com.name)
                                    if !com.mission.isEmpty {
                                        Text("Mission: \(com.mission)")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Join or Create Community")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $vm.showCreateForm) {
                CommunityCreateFormView(
                    proposedName: vm.searchQuery
                ) { newCom in
                    onSelectCommunity(newCom)
                    dismiss()
                }
            }
            .onAppear {
                vm.loadCommunities()
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

// MARK: CommunitySearchCreateViewModel.swift

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class CommunitySearchCreateViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var searchQuery: String = ""
    @Published var showCreateForm = false
    
    private let db = FirebaseManager.shared.db
    
    var filteredResults: [Community] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return communities
        }
        return communities.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var showCreateRow: Bool {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        return !communities.contains { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }
    }
    
    func loadCommunities() {
        db.collection("communities").getDocuments { snap, error in
            guard let docs = snap?.documents, error == nil else { return }
            self.communities = docs.compactMap { doc -> Community? in
                Community.fromDict(documentId: doc.documentID, dict: doc.data())
            }
        }
    }
}