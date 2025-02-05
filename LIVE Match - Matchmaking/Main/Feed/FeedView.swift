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
    
    // MARK: New Toggle for Objectionable Content
    @State private var filterObjectionable = false // Currently unused, placeholder only
    
    // MARK: - Composer
    @State private var showingComposer = false
    
    // MARK: - EULA
    @AppStorage("didAcceptEULA") private var didAcceptEULA = false
    @State private var showEULA = false
    
    // MARK: - Init
    public init() {}
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: Filter Menu
                DisclosureGroup("Feed Filters", isExpanded: $filterExpanded) {
                    Toggle("Everyone", isOn: $showEveryone)
                    Toggle("Friends", isOn: $showFriends)
                    Toggle("Following", isOn: $showFollowing)
                    Toggle("Creator Network", isOn: $showCreatorNetwork)
                    Toggle("Gaming", isOn: $showGaming)
                    Toggle("Agency", isOn: $showAgency)
                    
                    // MARK: New Objectionable Content Toggle
                    Toggle("Filter Objectionable Content", isOn: $filterObjectionable)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                
                // MARK: Feed Content
                if vm.posts.isEmpty {
                    Text("No posts to display.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                    Spacer()
                } else {
                    List(filteredPosts) { post in
                        PostRowView(post: post)
                    }
                    .listStyle(.plain)
                }
                
                // MARK: Create New Post
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
            .navigationTitle("Feed")
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
        // MARK: Check EULA onAppear
        .onAppear {
            // If EULA not accepted, present the EULA sheet
            if !didAcceptEULA {
                showEULA = true
            } else {
                // Otherwise fetch posts
                vm.fetchPosts()
            }
        }
        // MARK: EULA Sheet
        .sheet(isPresented: $showEULA, onDismiss: {
            // If user agreed in EULAView, then fetch posts
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
            // The new toggle 'filterObjectionable' is currently unused
            // Feel free to add real logic later if needed.
            
            if showEveryone {
                return true
            }
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
