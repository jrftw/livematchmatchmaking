// MARK: - PostRowView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays a single post with user info, plus Like/Comment/Follow buttons.

import SwiftUI
import AVKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PostRowView: View {
    @StateObject private var rowVM: PostRowViewModel
    public let post: Post
    
    public init(post: Post) {
        self.post = post
        _rowVM = StateObject(wrappedValue: PostRowViewModel(userId: post.userId))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User info row
            HStack(alignment: .top, spacing: 12) {
                // Profile pic
                if let picURL = rowVM.profilePicURL,
                   !picURL.isEmpty,
                   let url = URL(string: picURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 44, height: 44)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        case .failure(_):
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
                    
                    Text(post.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Post text
            if !post.text.isEmpty {
                Text(post.text)
                    .font(.body)
                    .padding(.top, 4)
            }
            
            // Post image
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
                    case .failure(_):
                        Color.red
                            .frame(height: 200)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Post video
            if let videoURL = post.videoURL, !videoURL.isEmpty {
                if let url = URL(string: videoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding(.vertical, 4)
                }
            }
            
            // Buttons row
            HStack(spacing: 30) {
                Button("Like") {
                    guard let postId = post.id else { return }
                    LikeService.shared.likePost(postId: postId) { _ in
                        // handle success/failure
                    }
                }
                Button("Comment") {
                    guard let postId = post.id else { return }
                    CommentService.shared.addComment(postId: postId, commentText: "Nice post!") { _ in
                        // handle success/failure
                    }
                }
                Button("Follow") {
                    FollowService.shared.followUser(targetUserId: post.userId) { _ in
                        // handle success/failure
                    }
                }
            }
            .font(.subheadline)
            .padding(.top, 6)
            
            Text(post.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
