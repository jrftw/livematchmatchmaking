//
//  HelpView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//
// MARK: HelpView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A placeholder "Help" screen for demonstration.
// Replace with your actual help/FAQ content as needed.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct HelpView: View {
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Help & FAQ")
                    .font(.title)
                    .padding(.top, 20)
                
                Text("Q: How do I sign up?\nA: Tap 'Create Account or Log In' from the main menu.")
                Text("Q: Why do I have to create an account?\nA: An account is needed to track your progress and achievements across devices.")
                Text("Q: Why can't I see certain items?\nA: Some features require an account. Log in to unlock them.")
                Text("Q: How do I reset my password?\nA: In the login screen, select 'Forgot Password' and follow the steps.")
                Text("Q: How can I check my login streak?\nA: Go to Achievements. Your streak is displayed under 'Current Login Streak'.")
                Text("Q: Where can I report bugs?\nA: Contact our support via the 'Settings' screen or email support@infinitumlive.com.")
                Text("Q: How do I invite friends?\nA: Look for the 'Invite a Friend' achievement and share your invitation link.")
                Text("Q: How do leaderboards work?\nA: Leaderboards display overall scores. Your rank updates automatically.")
                Text("Q: How do I establish my Agency or creator network?\nA: Go to your Profile > Edit Profile > Business Studio > Agency / Creator Network Section > Create New Agency / Network. To get verified as an actual agency or network, you must request verification.")
            }
            .padding()
        }
        .navigationTitle("Help")
    }
}
