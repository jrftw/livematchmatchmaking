// MARK: FillInBracketFinderView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------
// This view fetches available Fill-In brackets for users to select and fill.
// Ensures that brackets remain visible even after a user joins.
// Users will navigate to FillInBracketSlotsView to fill slots.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketFinderView: View {
    @StateObject private var vm = FillInBracketFinderViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                if vm.brackets.isEmpty {
                    Text("No available brackets found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(vm.brackets) { bracketDoc in
                        NavigationLink(
                            destination: FillInBracketSlotsView(bracket: bracketDoc)
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
            .navigationTitle("Find Slots to Fill")
        }
        .onAppear {
            vm.fetchVisibleBrackets()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class FillInBracketFinderViewModel: ObservableObject {
    @Published var brackets: [FillInBracketDoc] = []
    
    func fetchVisibleBrackets() {
        let db = FirebaseManager.shared.db
        guard let user = Auth.auth().currentUser else {
            // If not logged in, only show public
            fetchPublicBrackets()
            return
        }
        
        // For a logged-in user, we can do more complex checks. Basic approach:
        // fetch all documents, then filter in code. For large data, do separate queries.
        db.collection("fillInBrackets")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching fill-in brackets: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                do {
                    let items = try docs.compactMap { doc -> FillInBracketDoc? in
                        try doc.data(as: FillInBracketDoc.self)
                    }
                    DispatchQueue.main.async {
                        let filtered = items.filter { bracket in
                            if bracket.isPublic {
                                return true
                            } else {
                                // PRIVATE bracket => check user role, agency, or CN.
                                return self.isInAgencyOrCN(user, bracket)
                            }
                        }
                        self.brackets = filtered
                    }
                } catch {
                    print("Error decoding brackets: \(error.localizedDescription)")
                }
            }
    }
    
    private func fetchPublicBrackets() {
        let db = FirebaseManager.shared.db
        db.collection("fillInBrackets")
            .whereField("isPublic", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching public fill-in brackets: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                do {
                    let items = try docs.compactMap { doc -> FillInBracketDoc? in
                        try doc.data(as: FillInBracketDoc.self)
                    }
                    DispatchQueue.main.async {
                        self.brackets = items
                    }
                } catch {
                    print("Error decoding public brackets: \(error.localizedDescription)")
                }
            }
    }
    
    // Placeholder membership check
    private func isInAgencyOrCN(_ user: User, _ bracket: FillInBracketDoc) -> Bool {
        // Replace with real membership checks
        return false
    }
}
