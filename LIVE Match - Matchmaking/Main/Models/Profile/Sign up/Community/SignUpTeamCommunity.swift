//
//  SignUpTeamCommunity.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Team and Community sections as extension to SignUpMainContent.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public extension SignUpMainContent {
    // MARK: - Team & Community Section
    func teamCommunitySection() -> some View {
        Group {
            if mainAccountCategory == .solo {
                if selectedSoloTypes.contains(.viewer) || selectedSoloTypes.contains(.creator) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Join or Create a Team").font(.headline)
                        TextField("Team Name", text: $selectedTeamName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Search or Create Team") {
                            // Implementation
                        }
                        
                        Text("Join or Create a Community").font(.headline)
                        TextField("Community Name", text: $selectedCommunityName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Search or Create Community") {
                            // Implementation
                        }
                    }
                    .padding(.vertical, 8)
                }
            } else if mainAccountCategory == .community {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Community / Group Creation Date").font(.headline)
                    DatePicker("Founded On", selection: $birthday, displayedComponents: .date)
                }
                .padding(.vertical, 8)
            }
        }
    }
}
