// MARK: File 4: FeedView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays feed posts, supports multiple toggleable filters (Everyone, Friends, etc.),
// and adds a search bar to filter by text or author. Also allows clicking the author.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public enum FeedCategory: String, CaseIterable {
    case everyone = "Everyone"
    case friends = "Friends"
    case followingPlusFriends = "Following + Friends"
    case creatorNetwork = "Creator Network"
    case liveMatches = "LIVE Matches"
    case gaming = "Gaming"
    case agency = "Agency"
}

public struct FeedView: View {
    @StateObject private var vm = FeedViewModel()
    @State private var newPostText = ""
    
    // Toggles for each feed category
    @State private var enabledCategories: Set<FeedCategory> = [
        .everyone, .friends, .followingPlusFriends,
        .creatorNetwork, .liveMatches, .gaming, .agency
    ]
    
    // Search text
    @State private var searchText: String = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: Search Bar
            HStack {
                TextField("Search posts...", text: $searchText, onCommit: {
                    vm.applyFilters(enabled: enabledCategories, searchText: searchText)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button(action: {
                    searchText = ""
                    vm.applyFilters(enabled: enabledCategories, searchText: "")
                }) {
                    Text("Clear")
                }
                .padding(.trailing)
            }
            
            // MARK: Category Toggles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FeedCategory.allCases, id: \.self) { category in
                        Toggle(category.rawValue, isOn: Binding<Bool>(
                            get: { enabledCategories.contains(category) },
                            set: { newValue in
                                if newValue {
                                    enabledCategories.insert(category)
                                } else {
                                    enabledCategories.remove(category)
                                }
                                vm.applyFilters(enabled: enabledCategories, searchText: searchText)
                            }
                        ))
                        .toggleStyle(.button)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // MARK: Feed List
            List(vm.filteredPosts) { post in
                VStack(alignment: .leading, spacing: 6) {
                    Button {
                        vm.handleUserTap(authorID: post.authorID)
                    } label: {
                        Text("Author: \(post.authorID)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    Text(post.text)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // MARK: Post Creation
            HStack {
                TextField("What's on your mind?", text: $newPostText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Post") {
                    vm.createPost(text: newPostText)
                    newPostText = ""
                }
            }
            .padding()
        }
        .navigationTitle("Feed")
        .onAppear {
            vm.fetchPosts()
        }
    }
}

public final class FeedViewModel: ObservableObject {
    @Published public var posts: [FeedPost] = []
    @Published public var filteredPosts: [FeedPost] = []
    
    private let db = FirebaseManager.shared.db
    
    public init() {}
    
    // MARK: fetchPosts
    public func fetchPosts() {
        db.collection("feed")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snap, _ in
                guard let docs = snap?.documents else { return }
                self.posts = docs.compactMap { try? $0.data(as: FeedPost.self) }
                self.filteredPosts = self.posts // default
            }
    }
    
    // MARK: createPost
    public func createPost(text: String) {
        guard !text.isEmpty else { return }
        
        if Auth.auth().currentUser == nil {
            if AuthManager.shared.isGuest {
                let guestPost = FeedPost(
                    id: nil,
                    authorID: "Guest",
                    text: text,
                    mediaURL: nil,
                    timestamp: Date()
                )
                do {
                    try db.collection("feed").document().setData(from: guestPost)
                } catch {
                    print("Error creating guest post: \(error.localizedDescription)")
                }
            }
            return
        }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let post = FeedPost(
            id: nil,
            authorID: userID,
            text: text,
            mediaURL: nil,
            timestamp: Date()
        )
        do {
            try db.collection("feed").document().setData(from: post)
        } catch {
            print("Error creating post: \(error.localizedDescription)")
        }
    }
    
    // MARK: applyFilters
    public func applyFilters(enabled: Set<FeedCategory>, searchText: String) {
        var results = posts
        
        // Filter by category
        if !enabled.contains(.everyone) {
            // "Everyone" not included => we build a subset
            var subset: [FeedPost] = []
            
            for post in results {
                let lowerText = post.text.lowercased()
                var included = false
                
                // "friends" => user isFriend logic
                if enabled.contains(.friends), isFriend(with: post.authorID) {
                    included = true
                }
                // "creatorNetwork"
                if enabled.contains(.creatorNetwork), lowerText.contains("creator network") {
                    included = true
                }
                // "agency"
                if enabled.contains(.agency), lowerText.contains("agency") {
                    included = true
                }
                // "gaming"
                if enabled.contains(.gaming), lowerText.contains("gaming") {
                    included = true
                }
                // "liveMatches"
                if enabled.contains(.liveMatches), lowerText.contains("live match") {
                    included = true
                }
                // "followingPlusFriends"
                if enabled.contains(.followingPlusFriends), isFollowingOrFriend(with: post.authorID) {
                    included = true
                }
                
                if included {
                    subset.append(post)
                }
            }
            results = subset
        }
        
        // Filter by search text in the post text or author
        if !searchText.isEmpty {
            let lowerSearch = searchText.lowercased()
            results = results.filter {
                $0.text.lowercased().contains(lowerSearch) ||
                $0.authorID.lowercased().contains(lowerSearch)
            }
        }
        
        self.filteredPosts = results
    }
    
    // MARK: handleUserTap
    public func handleUserTap(authorID: String) {
        // Possibly navigate to that author's profile or show "follow/unfollow"
        print("User tapped author: \(authorID)")
    }
    
    // MARK: isFriend
    private func isFriend(with userID: String) -> Bool {
        // In a real app, you'd check friend/follow data in Firestore
        return false
    }
    
    // MARK: isFollowingOrFriend
    private func isFollowingOrFriend(with userID: String) -> Bool {
        // Placeholder logic
        return false
    }
}
