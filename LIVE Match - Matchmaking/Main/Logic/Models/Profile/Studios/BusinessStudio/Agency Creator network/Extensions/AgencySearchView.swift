//
//  AgencySearchView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//  A standalone screen for searching an existing Agency/Creator Network.
//  If `inCreatorMode == true`, we hide the "Create new agency" option
//  and display a message if no networks are found.
//
//  This way, from the Creator side, they can only join an existing network
//  and see "Creator Network not found, ask your agency or network to start one"
//  if none match.

import SwiftUI
import Firebase

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AgencySearchView: View {
    @Environment(\.dismiss) private var dismiss
    
    // If true, do NOT allow creation; only search existing.
    let inCreatorMode: Bool
    
    @StateObject private var vm = AgencySearchViewModel()
    let onSelectAgency: (String) -> Void
    
    public init(
        inCreatorMode: Bool = false, // default false for normal usage
        onSelectAgency: @escaping (String) -> Void
    ) {
        self.inCreatorMode = inCreatorMode
        self.onSelectAgency = onSelectAgency
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                TextField("Search Agency/Network", text: $vm.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                // If user typed a query and found zero matches,
                // and we are inCreatorMode => show "not found" message
                if vm.filteredAgencies.isEmpty,
                   !vm.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty,
                   inCreatorMode {
                    Text("Creator Network not found.\nAsk your agency or network to start one on our app.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                List {
                    // If not in creator mode, we can optionally show the "create" row
                    if !inCreatorMode, vm.showCreateOption {
                        Section("Create New Agency/Network") {
                            Button("Create \"\(vm.searchQuery)\"") {
                                vm.showCreateSheet = true
                            }
                        }
                    }
                    
                    Section("Existing Agencies") {
                        // If we have matches or user typed nothing
                        ForEach(vm.filteredAgencies, id: \.self) { name in
                            Button(name) {
                                onSelectAgency(name)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Agency / Network")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $vm.showCreateSheet) {
                // This only appears if !inCreatorMode and user typed new name
                AgencyCreateFormView(proposedName: vm.searchQuery) { createdName in
                    onSelectAgency(createdName)
                    dismiss()
                }
            }
            .onAppear {
                vm.loadAllAgencies()
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

// MARK: AgencySearchViewModel.swift
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class AgencySearchViewModel: ObservableObject {
    @Published var agencies: [String] = []
    @Published var searchQuery: String = ""
    @Published var showCreateSheet = false
    
    private let db = FirebaseManager.shared.db
    
    var filteredAgencies: [String] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return agencies
        }
        return agencies.filter {
            $0.localizedCaseInsensitiveContains(trimmed)
        }
    }
    
    /// Show "Create new" row if user typed something not in the list
    /// but only if we are not in Creator Mode (the actual check happens in the UI).
    var showCreateOption: Bool {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        
        return !agencies.contains { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
    }
    
    func loadAllAgencies() {
        db.collection("agencies").getDocuments { snap, err in
            guard let docs = snap?.documents, err == nil else { return }
            // Gather all existing agency "name" fields
            self.agencies = docs.compactMap { $0.data()["name"] as? String }
        }
    }
}
