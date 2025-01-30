//
//  ChatThread.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: ChatThreadModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Represents a chat thread (either group or one-on-one).

import Foundation
import FirebaseFirestore

public struct ChatThread: Identifiable, Codable {
    @DocumentID public var id: String?
    public var isGroup: Bool
    public var name: String?         // Group name if isGroup == true
    public var participants: [String] // Array of user IDs
    
    // For ordering by last message time
    public var lastUpdated: Date
    
    public init(
        id: String? = nil,
        isGroup: Bool,
        name: String? = nil,
        participants: [String],
        lastUpdated: Date
    ) {
        self.id = id
        self.isGroup = isGroup
        self.name = name
        self.participants = participants
        self.lastUpdated = lastUpdated
    }
}
