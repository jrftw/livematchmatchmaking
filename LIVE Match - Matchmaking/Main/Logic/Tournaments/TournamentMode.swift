//
//  TournamentMode.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


//
//  TournamentModels.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Defines the Tournament, TournamentMatch, Event, and TournamentMode data models.
//
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
enum TournamentMode: String, CaseIterable, Codable {
    case oneVone = "1v1"
    case twoVtwo = "2v2"
    case fourFFA = "1v1v1v1"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct Tournament: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var participants: [String]
    var matches: [TournamentMatch]
    var events: [Event]
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TournamentMatch: Codable, Identifiable {
    @DocumentID var id: String?
    var player1ID: String
    var player2ID: String
    var winnerID: String?
    var isComplete: Bool
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct Event: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var date: Date
    var participants: [String]
    var description: String
}
