//
//  TeamViewPlaceholder.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//


// MARK: File: TeamView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Placeholder or minimal real UI for the Team tab.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TeamViewPlaceholder: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Team View Placeholder")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationTitle("Team")
    }
}