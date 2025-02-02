//
//  ChangelogListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A separate list view for Changelog entries.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChangelogListView: View {
    // MARK: - Body
    public var body: some View {
        let _ = print("[ChangelogListView] body invoked. Building List.")
        
        List {
            ForEach(Changelog.entries) { entry in
                let _ = print("[ChangelogListView] Creating section for version: \(entry.version), build: \(entry.build)")
                
                Section(
                    header: Text("Version \(entry.version) (Build \(entry.build)) — Released \(entry.releaseDate)")
                ) {
                    ForEach(entry.changes, id: \.self) { line in
                        let _ = print("[ChangelogListView] Adding line: \(line)")
                        Text("• \(line)")
                    }
                }
            }
        }
    }
}
