//
//  TournamentCreationView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


// MARK: File: TournamentCreationView.swift
// MARK: A sheet allowing the user to input title, description, and pick 1v1, 2v2, or 1v1v1v1.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TournamentCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var titleText = ""
    @State private var descText = ""
    @State private var selectedMode: TournamentMode = .oneVone
    
    let onCreate: (String, String, TournamentMode) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Tournament Title", text: $titleText)
                }
                Section(header: Text("Description")) {
                    TextField("Description", text: $descText)
                }
                Section(header: Text("Mode")) {
                    Picker("Match Mode", selection: $selectedMode) {
                        ForEach(TournamentMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Button("Create") {
                    onCreate(titleText, descText, selectedMode)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("New Tournament")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}