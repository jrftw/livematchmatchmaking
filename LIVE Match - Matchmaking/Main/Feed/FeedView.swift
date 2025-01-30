//
//  FeedView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: FeedView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A container view displaying the feed with improved styling.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FeedView: View {
    @StateObject private var vm = FeedViewModel()
    
    @State private var filterExpanded = false
    @State private var showEveryone = true
    @State private var showFriends = false
    @State private var showFollowing = false
    @State private var showCreatorNetwork = false
    @State private var showGaming = false
    @State private var showAgency = false
    
    @State private var showingComposer = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DisclosureGroup("Feed Filters", isExpanded: $filterExpanded) {
                    Toggle("Everyone", isOn: $showEveryone)
                    Toggle("Friends", isOn: $showFriends)
                    Toggle("Following", isOn: $showFollowing)
                    Toggle("Creator Network", isOn: $showCreatorNetwork)
                    Toggle("Gaming", isOn: $showGaming)
                    Toggle("Agency", isOn: $showAgency)
                }
                .padding()
                
                Divider()
                
                if vm.posts.isEmpty {
                    Text("No posts to display.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    List {
                        ForEach(filteredPosts) { post in
                            PostRowView(post: post)
                        }
                    }
                    .listStyle(.plain)
                }
                
                if Auth.auth().currentUser != nil {
                    Button {
                        showingComposer = true
                    } label: {
                        Text("Create New Post")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Feed")
            .sheet(isPresented: $showingComposer) {
                PostComposerView { text, imageURL, videoURL in
                    vm.createPost(text: text, imageURL: imageURL, videoURL: videoURL)
                }
            }
        }
        .onAppear {
            vm.fetchPosts()
        }
    }
    
    private var filteredPosts: [Post] {
        vm.posts.filter { post in
            var showThisPost = false
            if showEveryone { showThisPost = true }
            if showFriends { showThisPost = showThisPost || false }
            if showFollowing { showThisPost = showThisPost || false }
            if showCreatorNetwork { showThisPost = showThisPost || false }
            if showGaming { showThisPost = showThisPost || false }
            if showAgency { showThisPost = showThisPost || false }
            return showThisPost
        }
    }
}