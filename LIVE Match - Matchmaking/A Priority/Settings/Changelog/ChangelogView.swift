//
//  ChangelogView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays a list of changes by version/build.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChangelogView: View {
    // MARK: - Init
    public init() {
        print("[ChangelogView] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[ChangelogView] body invoked. Building NavigationView.")
        
        NavigationView {
            ChangelogListView()
                .navigationTitle("Changelog")
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
