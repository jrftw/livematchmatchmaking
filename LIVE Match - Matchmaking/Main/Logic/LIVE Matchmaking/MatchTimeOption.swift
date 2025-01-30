//
//  MatchTimeOption.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


// MARK: File: LiveMatchmakingModels.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Public data types for the “Creator vs Creator” and bracket flows.

import Foundation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchTimeOption: String, CaseIterable {
    case now = "Now"
    case later = "Later"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchTypeOption: String, CaseIterable {
    case oneAndDone = "One and Done"
    case bestOf3 = "Best 2/3"
    case bestOf5 = "Best 3/5"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorMatchCandidate: Identifiable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}