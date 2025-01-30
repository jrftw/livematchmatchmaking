// MARK: FeedView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays toggles to filter feed: Everyone, Friends, Following, Creator Network, Gaming, Agency
// Then shows posts from users, tournaments, brackets, etc.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct FeedView: View {
    @State private var showEveryone = true
    @State private var showFriends = false
    @State private var showFollowing = false
    @State private var showCreatorNetwork = false
    @State private var showGaming = false
    @State private var showAgency = false
    
    var body: some View {
        VStack {
            Text("Feed")
                .font(.title)
                .padding(.top, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Toggle("Everyone", isOn: $showEveryone)
                    Toggle("Friends", isOn: $showFriends)
                    Toggle("Following", isOn: $showFollowing)
                    Toggle("Creator Network", isOn: $showCreatorNetwork)
                    Toggle("Gaming", isOn: $showGaming)
                    Toggle("Agency", isOn: $showAgency)
                }
                .padding()
            }
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Example placeholders based on toggles
                    if showEveryone {
                        Text("Showing Everyone's Posts/Events").font(.subheadline)
                    }
                    if showFriends {
                        Text("Friends Feed").font(.subheadline)
                    }
                    if showFollowing {
                        Text("Following Feed").font(.subheadline)
                    }
                    if showCreatorNetwork {
                        Text("Creator Network Posts").font(.subheadline)
                    }
                    if showGaming {
                        Text("Gaming Feed: Tournaments, Matches, etc.").font(.subheadline)
                    }
                    if showAgency {
                        Text("Agency Updates, Talent, Opportunities").font(.subheadline)
                    }
                    
                    // Real feed content would go here
                }
                .padding(.vertical, 20)
            }
        }
    }
}
