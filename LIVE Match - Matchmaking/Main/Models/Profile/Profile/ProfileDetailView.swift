//
//  PlatformDetailView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Allows selecting "Creator vs Creator" or bracket setups for a given platform.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PlatformDetailView: View {
    public let platform: LivePlatformOption
    
    public init(platform: LivePlatformOption) {
        self.platform = platform
    }
    
    public var body: some View {
        List {
            Section(header: Text("Match Options")) {
                NavigationLink("Creator vs Creator", destination: CreatorVsCreatorView(platform: platform))
            }
            Section(header: Text("Bracket Options")) {
                NavigationLink("CN Internal Bracket",
                               destination: AdvancedBracketCreationView(title: "CN Internal Bracket", platform: platform))
                NavigationLink("Agency Internal Bracket",
                               destination: AdvancedBracketCreationView(title: "Agency Internal Bracket", platform: platform))
                NavigationLink("Open Bracket",
                               destination: AdvancedBracketCreationView(title: "Open Bracket", platform: platform))
            }
        }
        .navigationTitle(platform.name)
    }
}
