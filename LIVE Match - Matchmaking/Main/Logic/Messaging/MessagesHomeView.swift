//
//  MessagesHomeView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: MessagesHomeView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Main messaging view with thread list, plus a button to show community chat.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MessagesHomeView: View {
    @State private var showCommunityChat = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                ThreadListView()
                
                Button {
                    showCommunityChat = true
                } label: {
                    Text("Open Community Chat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Messages")
            .sheet(isPresented: $showCommunityChat) {
                NavigationView {
                    ChatView()
                }
            }
        }
    }
}