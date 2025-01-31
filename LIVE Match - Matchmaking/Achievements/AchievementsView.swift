//
//  AchievementsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: AchievementsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Simple placeholder for Achievements. Replace with real logic as needed.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AchievementsView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Achievements")
                .font(.largeTitle)
                .padding(.top, 40)
            
            Text("Here you can view and manage your achievements, progress, and badges!")
                .font(.body)
                .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}