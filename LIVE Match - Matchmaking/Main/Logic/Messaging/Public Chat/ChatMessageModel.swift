//
//  ThreadMessage.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: ChatMessageModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Represents a message within a thread, with text, image, video, replies, reactions, etc.

import Foundation
import FirebaseFirestore

public struct ThreadMessage: Identifiable, Codable {
    @DocumentID public var id: String?
    public var senderID: String
    public var senderName: String
    public var text: String
    public var imageURL: String?
    public var videoURL: String?
    public var timestamp: Date
    
    // Reactions stored as a dictionary: reaction key -> array of user IDs
    public var reactions: [String: [String]]
    
    // Optional reply-to message ID
    public var replyTo: String?
    
    public init(
        id: String? = nil,
        senderID: String,
        senderName: String,
        text: String,
        imageURL: String? = nil,
        videoURL: String? = nil,
        timestamp: Date,
        reactions: [String: [String]] = [:],
        replyTo: String? = nil
    ) {
        self.id = id
        self.senderID = senderID
        self.senderName = senderName
        self.text = text
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.timestamp = timestamp
        self.reactions = reactions
        self.replyTo = replyTo
    }
}
