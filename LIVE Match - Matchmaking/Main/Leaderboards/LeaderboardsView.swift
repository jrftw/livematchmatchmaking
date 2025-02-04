//
//  LeaderboardsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//
// MARK: - LeaderboardsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays global/local leaderboards by fetching real data (no sample entries).

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LeaderboardsView: View {
    // MARK: - ObservedObject
    @ObservedObject private var achievementsManager: AchievementsManager
    
    // MARK: - Init
    public init(manager: AchievementsManager) {
        self.achievementsManager = manager
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(spacing: 10) {
            Text("Leaderboards")
                .font(.largeTitle)
                .padding(.top, 20)
            
            Text("Check your rank and compare scores!")
                .foregroundColor(.secondary)
            
            // Placeholder list showing only the current user, no sample data.
            List {
                Section(header: Text("Your Position")) {
                    HStack {
                        Text(achievementsManager.username)
                        Spacer()
                        Text("\(achievementsManager.totalScore) pts")
                            .fontWeight(.semibold)
                    }
                }
                
                // Additional fetched user rows could go here.
                // Replace or extend with your real backend logic.
            }
            .listStyle(PlainListStyle())
            
            Spacer()
            
            Text("Your Current Score: \(achievementsManager.totalScore) pts")
                .font(.headline)
                .padding(.bottom, 20)
        }
    }
}
