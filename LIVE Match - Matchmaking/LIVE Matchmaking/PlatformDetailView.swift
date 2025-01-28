//
//  PlatformDetailView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


// MARK: File 2: PlatformDetailView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// Allows selecting "Creator vs Creator" or bracket setups.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct PlatformDetailView: View {
    let platform: LivePlatformOption
    
    var body: some View {
        List {
            Section(header: Text("Match Options")) {
                NavigationLink("Creator vs Creator", destination: CreatorVsCreatorView(platform: platform))
            }
            
            Section(header: Text("Bracket Options")) {
                NavigationLink("CN Internal Bracket", destination: AdvancedBracketCreationView(title: "CN Internal Bracket", platform: platform))
                NavigationLink("Agency Internal Bracket", destination: AdvancedBracketCreationView(title: "Agency Internal Bracket", platform: platform))
                NavigationLink("Open Bracket", destination: AdvancedBracketCreationView(title: "Open Bracket", platform: platform))
            }
        }
        .navigationTitle(platform.name)
    }
}
