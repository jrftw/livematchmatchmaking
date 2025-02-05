//
//  AchievementsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//
// MARK: - AchievementsView.swift
// Displays achievements, progress, daily login/streak info.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AchievementsView: View {
    @ObservedObject private var achievementsManager: AchievementsManager
    
    public init(manager: AchievementsManager) {
        self.achievementsManager = manager
        print("[AchievementsView] init called.")
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Achievements")
                .font(.largeTitle)
                .padding(.top, 40)
            
            Text("Track your progress here!")
                .font(.body)
                .padding(.horizontal, 30)
            
            HStack {
                Text("Username:")
                Text(achievementsManager.username)
                    .fontWeight(.bold)
            }
            
            HStack {
                Text("Total Score:")
                Text("\(achievementsManager.totalScore)")
                    .fontWeight(.bold)
            }
            
            HStack {
                Text("Current Login Streak:")
                Text("\(achievementsManager.loginStreak) days")
                    .fontWeight(.bold)
            }
            
            List(achievementsManager.achievements, id: \.self) { achievement in
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.name)
                        .font(.headline)
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("Progress: \(achievement.currentProgress)/\(achievement.requiredProgress)")
                        Spacer()
                        Text(achievement.isUnlocked ? "Unlocked" : "Locked")
                            .foregroundColor(achievement.isUnlocked ? .green : .red)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Spacer()
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        // Register daily login each time the view appears
        .onAppear {
            achievementsManager.registerDailyLogin()
        }
    }
}
