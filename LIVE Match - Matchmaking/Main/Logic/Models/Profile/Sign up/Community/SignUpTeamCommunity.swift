// MARK: SignUpTeamCommunity.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Houses any missing subviews (teamCommunitySection, viewerLivePlatformSection, creatorLivePlatformSection, etc.)
// that SignUpMainContent references to avoid "Cannot find in scope" errors.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public extension SignUpMainContent {
    
    // MARK: - teamCommunitySection()
    func teamCommunitySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team / Community (Optional)").font(.headline)
            
            Text("Team Name (Join or Create)")
            TextField("Team Name", text: $selectedTeamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Search or Create Team") {
                // Implementation for searching or creating a team if needed
            }
            
            Text("Community Name (Join or Create)")
            TextField("Community Name", text: $selectedCommunityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Search or Create Community") {
                // Implementation for searching or creating a community if needed
            }
        }
        .padding(.vertical, 8)
    }
    
       
    // MARK: - gamerSectionView()
    func gamerSectionView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Gamer Accounts").font(.headline)
            ForEach(gamingAccounts) { account in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Username: \(account.username)")
                    Text("Teams/Communities: \(account.teamsOrCommunities.joined(separator: ", "))")
                }
                .padding(.vertical, 4)
            }
            HStack {
                TextField("New Gaming Username", text: $newGamingUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    let trimmed = newGamingUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    let newAcc = GamingAccountDetail(username: trimmed, teamsOrCommunities: [])
                    gamingAccounts.append(newAcc)
                    newGamingUsername = ""
                }
            }
            HStack {
                TextField("Add Team Name", text: $newGamingTeamInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add Team") {
                    let trimmed = newGamingTeamInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    newGamingTeams.append(trimmed)
                    newGamingTeamInput = ""
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - communityGroupCreationSection()
    func communityGroupCreationSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if selectedCommunityTypes.contains(.community) {
                Text("Create / Manage Community").font(.headline)
                DatePicker("Founded On", selection: $birthday, displayedComponents: .date)
            }
            if selectedCommunityTypes.contains(.group) {
                Text("Group Creation Info").font(.headline)
                DatePicker("Founded On", selection: $birthday, displayedComponents: .date)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - businessSection()
    func businessSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if selectedBusinessTypes.contains(.team) {
                Text("Business: Team Creation").font(.headline)
                TextField("Team Name", text: $selectedTeamName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Search or Create Team") { }
            }
            if selectedBusinessTypes.contains(.agency) {
                Text("Business: Agency Creation").font(.headline)
                TextField("Agency Name", text: $selectedCommunityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Search or Create Agency") { }
            }
            if selectedBusinessTypes.contains(.creatornetwork) {
                Text("Business: Creator Network Creation").font(.headline)
                TextField("Creator Network Name", text: $selectedTeamName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Search or Create Creator Network") { }
            }
            if selectedBusinessTypes.contains(.scouter) {
                Text("Scout: (Coming Soon)").font(.headline)
            }
        }
        .padding(.vertical, 8)
    }
}
