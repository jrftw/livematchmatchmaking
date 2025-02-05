// MARK: - PostRowView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays a single post with user info, plus Like/Comment/Follow/Block/Report actions.

import SwiftUI
import AVKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PostRowView: View {
    @StateObject private var rowVM: PostRowViewModel
    public let post: Post
    
    @State private var showCommentSheet = false
    @State private var commentText = ""
    
    public init(post: Post) {
        self.post = post
        _rowVM = StateObject(wrappedValue: PostRowViewModel(userId: post.userId, postId: post.id))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                if let picURL = rowVM.profilePicURL,
                   !picURL.isEmpty,
                   let url = URL(string: picURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 44, height: 44)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        case .failure:
                            Circle().fill(Color.gray)
                                .frame(width: 44, height: 44)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 44, height: 44)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        ProfileNavigationService.shared.showProfile(userId: post.userId)
                    } label: {
                        Text(post.username)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    
                    Text(post.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if !post.text.isEmpty {
                Text(post.text)
                    .font(.body)
                    .padding(.top, 4)
            }
            
            if let imageURL = post.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.vertical, 4)
                    case .failure:
                        Color.red
                            .frame(height: 200)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            if let videoURL = post.videoURL, !videoURL.isEmpty {
                if let url = URL(string: videoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding(.vertical, 4)
                }
            }
            
            HStack(spacing: 30) {
                Button(rowVM.isLiked ? "Unlike" : "Like") {
                    guard let postId = post.id else { return }
                    if rowVM.isLiked {
                        LikeService.shared.unlikePost(postId: postId) { _ in }
                    } else {
                        LikeService.shared.likePost(postId: postId) { _ in }
                    }
                }
                .buttonStyle(.plain)
                
                Button("Comment") {
                    showCommentSheet = true
                }
                .buttonStyle(.plain)
                
                Button(rowVM.isFollowing ? "Unfollow" : "Follow") {
                    if rowVM.isFollowing {
                        FollowService.shared.unfollowUser(targetUserId: post.userId) { _ in }
                    } else {
                        FollowService.shared.followUser(targetUserId: post.userId) { _ in }
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Menu {
                    Button("Block") {
                        BlockService.shared.blockUser(userId: post.userId) { _ in }
                    }
                    Button("Report") {
                        guard let postId = post.id else { return }
                        ReportService.shared.reportPost(postId: postId, reason: "Inappropriate Content") { _ in }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
            .font(.subheadline)
            .padding(.top, 6)
            
            Text(post.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showCommentSheet) {
            VStack(spacing: 16) {
                Text("Add a Comment").font(.headline)
                TextField("Type your comment here...", text: $commentText)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Spacer()
                    Button("Submit") {
                        guard let postId = post.id else { return }
                        CommentService.shared.addComment(postId: postId, commentText: commentText) { _ in }
                        showCommentSheet = false
                        commentText = ""
                    }
                    Button("Cancel") {
                        showCommentSheet = false
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}
