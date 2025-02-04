//
//  AgencyCNReviewView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//  A read-only list of all Agencies/Networks in the app.
//  Tapping on an agency navigates to AgencyDetailView (which we’ll conditionally allow editing).
//

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AgencyCNReviewView: View {
    @StateObject private var vm = AgencyCNReviewViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if vm.allAgencies.isEmpty {
                    Text("No agencies/networks found.")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                } else {
                    List(vm.allAgencies) { agency in
                        // Navigation to AgencyDetailView:
                        NavigationLink(destination: AgencyDetailView(agency: agency)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(agency.name)
                                    .font(.headline)
                                if !agency.founders.isEmpty {
                                    Text("Founders: \(agency.founders)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                if !agency.email.isEmpty {
                                    Text("Email: \(agency.email)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                if !agency.phoneNumber.isEmpty {
                                    Text("Phone: \(agency.phoneNumber)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("All Agencies/Networks")
            .onAppear {
                vm.fetchAllAgencies()
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class AgencyCNReviewViewModel: ObservableObject {
    @Published var allAgencies: [Agency] = []
    
    private let db = FirebaseManager.shared.db
    
    public init() {}
    
    /// Fetches *all* agencies in "agencies" collection
    public func fetchAllAgencies() {
        db.collection("agencies").getDocuments { snap, err in
            guard let docs = snap?.documents, err == nil else { return }
            
            let results = docs.compactMap { doc -> Agency? in
                let data = doc.data()
                return Agency.fromDict(data, docID: doc.documentID)
            }
            DispatchQueue.main.async {
                self.allAgencies = results
            }
        }
    }
}
