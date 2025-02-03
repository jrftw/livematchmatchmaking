// =============================
// MARK: CreatorVsCreatorView.swift
// =============================

//
//  CreatorVsCreatorView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  “Tinder style” approach for scheduling Creator vs. Creator matches.
//  Uses data models from MatchModels.swift
//  Loads real creator data from Firebase, then offers swipe decisions.
//

import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorVsCreatorView: View {
    
    public let platform: LivePlatformOption
    
    @State private var selectedTime: MatchTimeOption = .now
    @State private var selectedType: MatchTypeOption = .oneAndDone
    
    @State private var selectedLaterOption: String? = nil
    private let possibleLaterOptions = [
        "Within 1 day", "Within 2 days", "Within 1 week",
        "Within 2 weeks", "Within 3 weeks", "Within 1 month"
    ]
    
    @State private var potentialMatches: [CreatorMatchCandidate] = []
    @State private var decisionHistory: [String: SwipeDecision] = [:]
    
    // Loading / Error
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public init(platform: LivePlatformOption) {
        self.platform = platform
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            timeAndTypeSection()
            
            if selectedTime == .later {
                laterSchedulingSection()
            }
            
            Text("Creators Searching on \(platform.name)")
                .font(.headline)
            
            if isLoading {
                ProgressView("Loading matches...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let currentCandidate = potentialMatches.first {
                candidateCard(candidate: currentCandidate)
            } else {
                Text("No more creators to match with.")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            NavigationLink("View Decision History") {
                historyListView()
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .navigationTitle("Creator vs Creator")
        .padding()
        .task {
            await loadPotentialMatchesFromFirebase()
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
private extension CreatorVsCreatorView {
    
    func timeAndTypeSection() -> some View {
        VStack(spacing: 12) {
            Picker("Time Option", selection: $selectedTime) {
                ForEach(MatchTimeOption.allCases, id: \.self) { opt in
                    Text(opt.rawValue)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Match Format", selection: $selectedType) {
                ForEach(MatchTypeOption.allCases, id: \.self) { mt in
                    Text(mt.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
    
    func laterSchedulingSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Schedule (up to 1 month):").font(.subheadline)
            ForEach(possibleLaterOptions, id: \.self) { opt in
                HStack {
                    Button {
                        selectedLaterOption = (selectedLaterOption == opt ? nil : opt)
                    } label: {
                        HStack {
                            Image(systemName: selectedLaterOption == opt
                                  ? "checkmark.square.fill"
                                  : "square")
                            Text(opt)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
    
    func candidateCard(candidate: CreatorMatchCandidate) -> some View {
        VStack(spacing: 12) {
            if let url = URL(string: candidate.profilePictureURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
            }
            
            Text(candidate.username).font(.title2)
            Text(candidate.bio)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Location: \(candidate.location)")
                .font(.subheadline)
            
            HStack(spacing: 40) {
                Button {
                    swipe(.no, for: candidate)
                } label: {
                    Label("No", systemImage: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                Button {
                    swipe(.maybe, for: candidate)
                } label: {
                    Label("Maybe", systemImage: "questionmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                Button {
                    swipe(.yes, for: candidate)
                } label: {
                    Label("Yes", systemImage: "checkmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 6)
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
        .frame(maxWidth: 350)
    }
    
    func swipe(_ decision: SwipeDecision, for candidate: CreatorMatchCandidate) {
        decisionHistory[candidate.id] = decision
        potentialMatches.removeAll { $0.id == candidate.id }
    }
    
    func historyListView() -> some View {
        List {
            ForEach(decisionHistory.sorted(by: { $0.key < $1.key }), id: \.key) { (candidateID, dec) in
                HStack {
                    Text("Candidate ID: \(candidateID)")
                    Spacer()
                    Text(dec.rawValue.capitalized)
                        .foregroundColor(
                            dec == .yes ? .green :
                            dec == .no ? .red : .orange
                        )
                }
            }
        }
        .navigationTitle("Decision History")
    }
    
    func loadPotentialMatchesFromFirebase() async {
        isLoading = true
        errorMessage = nil
        
        let db = FirebaseManager.shared.db
        do {
            let querySnap = try await db.collection("creators")
                .whereField("platform", isEqualTo: platform.name)
                .getDocuments()
            
            var loaded: [CreatorMatchCandidate] = []
            for doc in querySnap.documents {
                let data = doc.data()
                guard
                    let username = data["username"] as? String,
                    let bio = data["bio"] as? String,
                    let location = data["location"] as? String,
                    let profilePictureURL = data["profilePictureURL"] as? String
                else { continue }
                
                let candidate = CreatorMatchCandidate(
                    id: doc.documentID,
                    username: username,
                    bio: bio,
                    location: location,
                    profilePictureURL: profilePictureURL
                )
                loaded.append(candidate)
            }
            potentialMatches = loaded
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
