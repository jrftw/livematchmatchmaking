//
//  FillInBracketDoc.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Firestore model for a “Fill-In Bracket” document.
//

import SwiftUI
import FirebaseFirestore

// MARK: - FillInBracketDoc
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketDoc: Identifiable, Codable {
    @DocumentID public var id: String?
    public var bracketName: String
    public var platformName: String
    public var slots: [FillInBracketSlot]
    public var createdByUserID: String?
    public var createdAt: Date
    
    public init(
        id: String? = nil,
        bracketName: String,
        platformName: String,
        slots: [FillInBracketSlot],
        createdByUserID: String? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.bracketName = bracketName
        self.platformName = platformName
        self.slots = slots
        self.createdByUserID = createdByUserID
        self.createdAt = createdAt
    }
}

/*
 // MARK: - (Deprecated duplicate, commented out to avoid conflicts)
 // The advanced FillInBracketSlot is defined in FillInBracketSlot.swift
 //public struct FillInBracketSlot: Identifiable, Codable {
 //    public var id: String = UUID().uuidString
 //    public var name: String
 //    public init(name: String) {
 //        self.name = name
 //    }
 //}
*/
