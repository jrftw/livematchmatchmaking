//
//  CreatorVsCreatorView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  “Tinder style” approach for scheduling Creator vs. Creator matches.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorVsCreatorView: View {
    public let platform: LivePlatformOption
    
    @State private var selectedTime: MatchTimeOption = .now
    @State private var selectedType: MatchTypeOption = .oneAndDone
    
    @State private var potentialMatches: [CreatorMatchCandidate] = [
        .init(id: "1", name: "CreatorAlpha"),
        .init(id: "2", name: "CreatorBeta"),
        .init(id: "3", name: "CreatorGamma"),
    ]
    
    public init(platform: LivePlatformOption) {
        self.platform = platform
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Picker("Time Option", selection: $selectedTime) {
                ForEach(MatchTimeOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Picker("Type", selection: $selectedType) {
                ForEach(MatchTypeOption.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Text("Swipe to match (Placeholder)")
                .font(.headline)
            
            if let topCandidate = potentialMatches.first {
                VStack(spacing: 12) {
                    Text(topCandidate.name)
                        .font(.title2)
                    
                    HStack {
                        Button("Swipe Left (No)") {
                            swipeLeft()
                        }
                        Spacer()
                        Button("Swipe Right (Yes)") {
                            swipeRight()
                        }
                    }
                    .padding(.horizontal, 50)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            } else {
                Text("No more creators to match with.")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .navigationTitle("Creator vs Creator")
        .padding()
    }
    
    private func swipeLeft() {
        guard !potentialMatches.isEmpty else { return }
        potentialMatches.removeFirst()
    }
    
    private func swipeRight() {
        guard !potentialMatches.isEmpty else { return }
        // Possibly schedule a match, store in Firestore, etc.
        potentialMatches.removeFirst()
    }
}
