// MARK: - FeedView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays a filtered feed and a sheet for creating new posts,
// with an EULA sheet shown first if the user hasn't agreed yet.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FeedView: View {
    // MARK: - View Model
    @StateObject private var vm = FeedViewModel()
    
    // MARK: - Filter Toggles
    @State private var filterExpanded = false
    @State private var showEveryone = true
    @State private var showFriends = false
    @State private var showFollowing = false
    @State private var showCreatorNetwork = false
    @State private var showGaming = false
    @State private var showAgency = false
    
    // MARK: New Toggle for Objectionable Content (currently unused)
    @State private var filterObjectionable = false
    
    // MARK: - Composer
    @State private var showingComposer = false
    
    // MARK: - EULA
    @AppStorage("didAcceptEULA") private var didAcceptEULA = false
    @State private var showEULA = false
    
    // MARK: - Init
    public init() {}
    
    // MARK: - Body
    public var body: some View {
        // We create a ZStack so we can place everything under the status bar area.
        NavigationView {
            ZStack(alignment: .top) {
                
                // Main content below
                VStack(spacing: 0) {
                    Spacer()
                }
                .padding(.top, 120) // Push down main content to accommodate top area
                
                // Overlay the top container
                VStack(spacing: 0) {
                    
                    // Custom top area (mimics a nav bar region)
                    HStack {
                        Text("Feed")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Filter Menu pinned just below the title
                    DisclosureGroup("Feed Filters", isExpanded: $filterExpanded) {
                        Toggle("Everyone", isOn: $showEveryone)
                        Toggle("Friends", isOn: $showFriends)
                        Toggle("Following", isOn: $showFollowing)
                        Toggle("Creator Network", isOn: $showCreatorNetwork)
                        Toggle("Gaming", isOn: $showGaming)
                        Toggle("Agency", isOn: $showAgency)
                        Toggle("Filter Objectionable Content", isOn: $filterObjectionable)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // List or "No posts" content
                    if vm.posts.isEmpty {
                        Spacer()
                        Text("No posts to display.")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        List {
                            // Insert a banner ad every 5th post
                            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
                                if index != 0 && index % 5 == 0 {
                                    #if canImport(UIKit)
                                    BannerAdView()
                                    #endif
                                }
                                PostRowView(post: post)
                            }
                        }
                        .listStyle(.plain)
                    }
                    
                    // Create New Post
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
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingComposer) {
                PostComposerView { text, images, optionalVideoURL, taggedUsers in
                    vm.createPost(
                        text: text,
                        images: images,
                        videoURL: optionalVideoURL,
                        taggedUsers: taggedUsers
                    )
                }
            }
        }
        // Check EULA onAppear
        .onAppear {
            if !didAcceptEULA {
                showEULA = true
            } else {
                vm.fetchPosts()
            }
        }
        // EULA Sheet
        .sheet(isPresented: $showEULA, onDismiss: {
            if didAcceptEULA {
                vm.fetchPosts()
            }
        }) {
            EULAView()
        }
    }
    
    // MARK: - Filtered Posts
    private var filteredPosts: [Post] {
        vm.posts.filter { post in
            // 'filterObjectionable' currently not in use, placeholder only.
            if showEveryone { return true }
            var matches = false
            if showFriends && post.category == "Friends" { matches = true }
            if showFollowing && post.category == "Following" { matches = true }
            if showCreatorNetwork && post.category == "CreatorNetwork" { matches = true }
            if showGaming && post.category == "Gaming" { matches = true }
            if showAgency && post.category == "Agency" { matches = true }
            return matches
        }
    }
}
