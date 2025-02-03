//
//  ChatMessage.swift
//  LIVE Match - Matchmaking
//
//  Stores a single chat message with senderUID, text, and timestamp.
//

import Foundation

public struct ChatMessage: Identifiable {
    public let id: String
    public let text: String
    public let senderUID: String
    public let timestamp: Date
}
