//
//  CommentListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/10/25.
//


// MARK: - CommentListView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays a list of comments for a particular post in a feed-like style.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CommentListView: View {
    @StateObject private var viewModel: CommentListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    public init(postId: String) {
        _viewModel = StateObject(wrappedValue: CommentListViewModel(postId: postId))
    }
    
    public var body: some View {
        NavigationView {
            List(viewModel.comments) { comment in
                VStack(alignment: .leading, spacing: 6) {
                    Text(comment.username)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text(comment.text)
                        .font(.body)
                    Text(comment.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}