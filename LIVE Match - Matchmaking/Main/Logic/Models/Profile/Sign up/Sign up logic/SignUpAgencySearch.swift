// MARK: SignUpAgencySearch.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension SignUpMainContent {
    func agencyNetworkSearchView() -> some View {
        NavigationView {
            VStack {
                Text("Search for Agency / Creator Network")
                    .font(.headline)
                    .padding(.top)
                
                TextField("Search or Add New", text: $agencySearchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                List {
                    ForEach(filterAgencies(), id: \.self) { name in
                        Button {
                            if !selectedAgencyName.isEmpty {
                                agencyOrNetworkNames[selectedAgencyName] = name
                            }
                            showingAgencySearch = false
                        } label: {
                            Text(name)
                        }
                    }
                    if !agencySearchText.isEmpty && !filterAgencies().contains(agencySearchText) {
                        Button("Create '\(agencySearchText)'") {
                            if !selectedAgencyName.isEmpty {
                                agencyOrNetworkNames[selectedAgencyName] = agencySearchText
                            }
                            showingAgencySearch = false
                        }
                    }
                }
            }
            .navigationTitle("Agency Search")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAgencySearch = false
                    }
                }
            }
        }
    }
    
    func filterAgencies() -> [String] {
        if agencySearchText.isEmpty {
            return defaultAgencies
        }
        let lowerSearch = agencySearchText.lowercased()
        return defaultAgencies.filter { $0.lowercased().contains(lowerSearch) }
    }
}
