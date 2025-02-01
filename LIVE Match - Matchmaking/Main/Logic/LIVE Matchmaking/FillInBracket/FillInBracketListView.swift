//
//  FillInBracketListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Lists existing fill-in bracket docs from Firestore for a given platform
//  and opens them in FillInBracketCreationView.
//

import SwiftUI
import FirebaseFirestore

// MARK: - FillInBracketListView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct FillInBracketListView: View {
    let platform: LivePlatformOption
    @StateObject private var vm = FillInBracketListViewModel()
    
    var body: some View {
        List {
            if vm.brackets.isEmpty {
                Text("No fill-in brackets found for \(platform.name).")
                    .foregroundColor(.secondary)
            } else {
                ForEach(vm.brackets) { bracketDoc in
                    NavigationLink(
                        destination: FillInBracketCreationView(
                            title: bracketDoc.bracketName,
                            platform: LivePlatformOption(name: bracketDoc.platformName),
                            existingDoc: bracketDoc
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bracketDoc.bracketName)
                                .font(.headline)
                            Text("Slots: \(bracketDoc.slots.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select a Bracket")
        .onAppear {
            vm.fetchBrackets(platformName: platform.name)
        }
    }
}

// MARK: - FillInBracketListViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class FillInBracketListViewModel: ObservableObject {
    @Published var brackets: [FillInBracketDoc] = []
    
    func fetchBrackets(platformName: String) {
        let db = FirebaseManager.shared.db
        db.collection("fillInBrackets")
            .whereField("platformName", isEqualTo: platformName)
            .getDocuments { snap, err in
                if let err = err {
                    print("Error fetching fill-in brackets: \(err.localizedDescription)")
                    return
                }
                guard let snap = snap else { return }
                do {
                    let docs = try snap.documents.compactMap { doc -> FillInBracketDoc? in
                        try doc.data(as: FillInBracketDoc.self)
                    }
                    DispatchQueue.main.async {
                        self.brackets = docs
                    }
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                }
            }
    }
}
