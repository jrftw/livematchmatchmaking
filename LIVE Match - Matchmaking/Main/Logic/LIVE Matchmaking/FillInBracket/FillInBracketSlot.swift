//
//  FillInBracketSlot.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Stores a single bracket slot with date/time and two creators.

import Foundation

// MARK: - FillInBracketSlot
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketSlot: Identifiable, Codable {
    public let id: UUID
    public var startDateTime: Date
    public var creator1: String
    public var creatorNetworkOrAgency1: String
    public var category1: String
    public var diamondAvg1: String
    public var creator2: String
    public var creatorNetworkOrAgency2: String
    public var category2: String
    public var diamondAvg2: String
    public var status: MatchStatus
    public var notes: String
    public var link: String
    
    public init(
        id: UUID = UUID(),
        startDateTime: Date = Date(),
        creator1: String = "",
        creatorNetworkOrAgency1: String = "",
        category1: String = "",
        diamondAvg1: String = "",
        creator2: String = "",
        creatorNetworkOrAgency2: String = "",
        category2: String = "",
        diamondAvg2: String = "",
        status: MatchStatus = .pending,
        notes: String = "",
        link: String = ""
    ) {
        self.id = id
        self.startDateTime = startDateTime
        self.creator1 = creator1
        self.creatorNetworkOrAgency1 = creatorNetworkOrAgency1
        self.category1 = category1
        self.diamondAvg1 = diamondAvg1
        self.creator2 = creator2
        self.creatorNetworkOrAgency2 = creatorNetworkOrAgency2
        self.category2 = category2
        self.diamondAvg2 = diamondAvg2
        self.status = status
        self.notes = notes
        self.link = link
    }
}
