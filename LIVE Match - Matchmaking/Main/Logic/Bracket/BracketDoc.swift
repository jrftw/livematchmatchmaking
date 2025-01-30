//
//  BracketDoc.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: BracketDoc.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A Firestore model representing a bracket document.

import Foundation
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct BracketDoc: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let bracketName: String
    let bracketCreator: String
    let platform: String
    let startTime: Date
    let stopTime: Date
    let timezone: String
    let bracketStyle: String
    let maxUsers: Int?
    // If you have participants, store them here:
    // let participants: [ParticipantDoc]?
}
