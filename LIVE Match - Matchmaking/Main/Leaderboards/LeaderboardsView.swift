//
//  LeaderboardsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


// MARK: LeaderboardsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays global or local leaderboards for relevant stats.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct LeaderboardsView: View {
    var body: some View {
        VStack {
            Text("Leaderboards")
                .font(.largeTitle)
                .padding(.top, 20)
            
            Spacer()
            
            // Implementation for scoreboard rows
            Text("Top Gamers / Creators / Teams go here.")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}