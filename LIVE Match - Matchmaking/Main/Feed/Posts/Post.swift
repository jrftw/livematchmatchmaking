// MARK: - Post.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Make sure your user doc has "username" (or whatever you choose) and "profilePictureURL" fields.

import SwiftUI
import FirebaseFirestore

public struct Post: Identifiable, Codable {
    @DocumentID public var id: String?
    public var userId: String
    public var username: String
    public var text: String
    public var imageURL: String?
    public var videoURL: String?
    public var timestamp: Date
    public var category: String?
    public var taggedUsers: [String]
    
    public init(
        id: String? = nil,
        userId: String,
        username: String,
        text: String,
        imageURL: String? = nil,
        videoURL: String? = nil,
        timestamp: Date,
        category: String? = nil,
        taggedUsers: [String] = []
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.text = text
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.timestamp = timestamp
        self.category = category
        self.taggedUsers = taggedUsers
    }
}
