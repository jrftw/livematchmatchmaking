//
//  CreatorVsCreatorView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  “Tinder style” approach for scheduling Creator vs. Creator matches.
//  Allows user to pick match time (Now or up to 1 month), match format,
//  displays searching creators with user pictures, bios, & location.
//  Provides Yes/No/Maybe, keeps a local decision history.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorVsCreatorView: View {
    
    public let platform: LivePlatformOption
    
    // Time & Format
    @State private var selectedTime: MatchTimeOption = .now
    @State private var selectedType: MatchTypeOption = .oneAndDone
    
    // For “Later” scheduling
    @State private var selectedLaterOption: String? = nil
    private let possibleLaterOptions = [
        "Within 1 day", "Within 2 days", "Within 1 week",
        "Within 2 weeks", "Within 3 weeks", "Within 1 month"
    ]
    
    // Deck of potential matches
    @State private var potentialMatches: [CreatorMatchCandidate] = [
        .init(
            id: "1",
            username: "CreatorAlpha",
            bio: "Pro at dance battles",
            location: "New York, USA",
            profilePictureURL: "https://example.com/alpha.jpg"
        ),
        .init(
            id: "2",
            username: "CreatorBeta",
            bio: "Loves singing duels",
            location: "Los Angeles, USA",
            profilePictureURL: "https://example.com/beta.jpg"
        ),
        .init(
            id: "3",
            username: "CreatorGamma",
            bio: "Comedic skits champion",
            location: "London, UK",
            profilePictureURL: "https://example.com/gamma.jpg"
        )
    ]
    
    // Decision history
    @State private var decisionHistory: [String: SwipeDecision] = [:]
    
    public init(platform: LivePlatformOption) {
        self.platform = platform
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            
            // Time & Type pickers
            timeAndTypeSection()
            
            if selectedTime == .later {
                laterSchedulingSection()
            }
            
            Text("Creators Searching on \(platform.name)")
                .font(.headline)
            
            if let currentCandidate = potentialMatches.first {
                candidateCard(candidate: currentCandidate)
            } else {
                Text("No more creators to match with.")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            // History
            NavigationLink("View Decision History") {
                historyListView()
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .navigationTitle("Creator vs Creator")
        .padding()
    }
}

// MARK: - Private Helpers
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
private extension CreatorVsCreatorView {
    
    // Time & Format
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
    
    // For "Later" scheduling
    func laterSchedulingSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Schedule (up to 1 month):").font(.subheadline)
            ForEach(possibleLaterOptions, id: \.self) { opt in
                HStack {
                    Button {
                        if selectedLaterOption == opt {
                            selectedLaterOption = nil
                        } else {
                            selectedLaterOption = opt
                        }
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
    
    // Card for current top candidate
    func candidateCard(candidate: CreatorMatchCandidate) -> some View {
        VStack(spacing: 12) {
            // Picture
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
            
            // Buttons: No, Maybe, Yes
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
    
    // Record decision & remove candidate
    func swipe(_ decision: SwipeDecision, for candidate: CreatorMatchCandidate) {
        decisionHistory[candidate.id] = decision
        potentialMatches.removeAll { $0.id == candidate.id }
    }
    
    // Past decisions
    func historyListView() -> some View {
        List {
            ForEach(decisionHistory.sorted(by: { $0.key < $1.key }), id: \.key) { (candidateID, dec) in
                HStack {
                    Text("Candidate ID: \(candidateID)")
                    Spacer()
                    Text(dec.rawValue.capitalized)
                        .foregroundColor(dec == .yes ? .green
                                         : dec == .no ? .red
                                         : .orange)
                }
            }
        }
        .navigationTitle("Decision History")
    }
}
