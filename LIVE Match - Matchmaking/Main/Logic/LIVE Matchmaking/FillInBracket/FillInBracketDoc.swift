// FILE: FillInBracketDoc.swift
// UPDATED FILE

import SwiftUI
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketDoc: Identifiable, Codable {
    @DocumentID public var id: String?
    public var bracketName: String
    public var platformName: String
    public var slots: [FillInBracketSlot]
    public var createdByUserID: String?
    public var createdAt: Date
    
    // NEW: Whether this bracket is visible to everyone (public) or restricted
    public var isPublic: Bool
    
    public init(
        id: String? = nil,
        bracketName: String,
        platformName: String,
        slots: [FillInBracketSlot],
        createdByUserID: String? = nil,
        createdAt: Date,
        isPublic: Bool = true
    ) {
        self.id = id
        self.bracketName = bracketName
        self.platformName = platformName
        self.slots = slots
        self.createdByUserID = createdByUserID
        self.createdAt = createdAt
        self.isPublic = isPublic
    }
}
