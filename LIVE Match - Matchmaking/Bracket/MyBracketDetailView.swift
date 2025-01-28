//
//  MyBracketDetailView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: MyBracketDetailView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct MyBracketDetailView: View {
    @State var bracket: BracketDoc
    @State private var showDeleteConfirm = false
    @State private var showDuplicateConfirm = false
    
    var body: some View {
        Form {
            Section(header: Text("Bracket Info")) {
                Text("Name: \(bracket.bracketName)")
                Text("Platform: \(bracket.platform)")
                Text("Creator: \(bracket.bracketCreator)")
                Text("Starts: \(bracket.startTime.description)")
                Text("Ends: \(bracket.stopTime.description)")
                Text("Style: \(bracket.bracketStyle)")
                Text("Max Users: \(bracket.maxUsers.map(String.init) ?? "Unlimited")")
            }
            
            Section {
                Button("Edit Bracket") {
                    // Possibly navigate to an edit screen or inline form
                    // That updates the bracket doc
                }
                Button("Duplicate Bracket") {
                    showDuplicateConfirm = true
                }
                .foregroundColor(.blue)
                
                Button("Delete Bracket") {
                    showDeleteConfirm = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle(bracket.bracketName)
        .alert("Confirm Deletion", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                deleteBracket()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this bracket?")
        }
        .alert("Duplicate Bracket?", isPresented: $showDuplicateConfirm) {
            Button("Duplicate", role: .none) {
                duplicateBracket()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Create a copy of this bracket?")
        }
    }
    
    private func deleteBracket() {
        guard let bracketID = bracket.id else { return }
        let db = FirebaseManager.shared.db
        db.collection("brackets").document(bracketID).delete { err in
            if let err = err {
                print("Error deleting bracket: \(err.localizedDescription)")
            } else {
                print("Bracket deleted.")
            }
        }
    }
    
    private func duplicateBracket() {
        // Make a copy with a new doc ID
        let copyDoc: [String: Any] = [
            "title": bracket.title + " (Copy)",
            "bracketName": bracket.bracketName + " (Copy)",
            "bracketCreator": bracket.bracketCreator,
            "platform": bracket.platform,
            "startTime": bracket.startTime,
            "stopTime": bracket.stopTime,
            "timezone": bracket.timezone,
            "bracketStyle": bracket.bracketStyle,
            "maxUsers": bracket.maxUsers as Any
        ]
        let db = FirebaseManager.shared.db
        db.collection("brackets").addDocument(data: copyDoc) { err in
            if let err = err {
                print("Error duplicating bracket: \(err.localizedDescription)")
            } else {
                print("Bracket duplicated.")
            }
        }
    }
}
