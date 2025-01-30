//
//  ManageBusinessView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


// MARK: ManageBusinessView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// For agencies, creator networks, teams, or scouters to manage their business features.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ManageBusinessView: View {
    var body: some View {
        VStack {
            Text("Manage Your Business")
                .font(.title)
                .padding(.top, 20)
            
            Spacer()
            Text("Business management tools go here.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle("Manage Business")
    }
}