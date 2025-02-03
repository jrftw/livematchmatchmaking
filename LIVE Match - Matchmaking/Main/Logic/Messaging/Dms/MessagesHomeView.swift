//
//  MessagesHomeView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  Main messaging view with thread list, plus a button to show community chat.
//  Improved layout: a gradient background, card-like ThreadList, and a more
//  visually separated "Open Community Chat" button at the bottom.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MessagesHomeView: View {
    @State private var showCommunityChat = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [.white, .gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 16) {
                    // Thread List
                    VStack(spacing: 0) {
                        Text("Your Threads")
                            .font(.headline)
                            .padding(.top, 12)
                        
                        // If ThreadListView is a custom view, wrap in a container
                        // or style as needed:
                        ThreadListView()
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground).opacity(0.9))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Community Chat Button
                    Button {
                        showCommunityChat = true
                    } label: {
                        Text("Open Community Chat")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCommunityChat) {
                NavigationView {
                    ChatView()
                        .navigationTitle("Community Chat")
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
