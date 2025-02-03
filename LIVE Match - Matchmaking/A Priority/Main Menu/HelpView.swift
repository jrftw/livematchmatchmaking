//
//  HelpView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


//
//  HelpView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  A placeholder "Help" screen for demonstration. 
//  You can replace with your actual help/FAQ content.
//

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
                Text("Q: Why can't I see certain items?\nA: Some features require an account. Log in to unlock them.")
                // ... more placeholders
            }
            .padding()
        }
        .navigationTitle("Help")
    }
}