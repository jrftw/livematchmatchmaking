//
//  ManageCommunityView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


// MARK: ManageCommunityView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows communities to manage members, events, announcements.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ManageCommunityView: View {
    var body: some View {
        VStack {
            Text("Manage Your Community")
                .font(.title)
                .padding(.top, 20)
            
            Spacer()
            Text("Community management tools go here.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle("Manage Community")
    }
}