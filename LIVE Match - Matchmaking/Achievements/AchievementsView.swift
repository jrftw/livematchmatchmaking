//
//  AchievementsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//
// MARK: - AchievementsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Simple placeholder for Achievements. Replace or expand with real logic as needed.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AchievementsView: View {
    // MARK: - Init
    public init() {
        print("[AchievementsView] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[AchievementsView] body invoked. Building achievements UI.")
        
        VStack(spacing: 20) {
            let _ = print("[AchievementsView] Adding title text => 'Achievements'.")
            Text("Achievements")
                .font(.largeTitle)
                .padding(.top, 40)
            
            let _ = print("[AchievementsView] Adding description text => 'Here you can view and manage your achievements, ...'.")
            Text("Here you can view and manage your achievements, progress, and badges!")
                .font(.body)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
