//
//  MessagesHomeView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  A cleaner tab-based UI for direct messages, group threads, and community chat.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MessagesHomeView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        // A three-tab interface
        TabView(selection: $selectedTab) {
            
            // 1) Direct Messages
            NavigationView {
                DirectMessagesListView()
            }
            .tabItem {
                Label("Direct", systemImage: "person.fill")
            }
            .tag(0)
            
            // 2) Group Threads
            NavigationView {
                ThreadListView()
            }
            .tabItem {
                Label("Groups", systemImage: "person.2.fill")
            }
            .tag(1)
            
            // 3) Community Chat
            NavigationView {
                ChatView()
                    .navigationTitle("Community Chat")
            }
            .tabItem {
                Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(2)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // For iOS devices
    }
}
