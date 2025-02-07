// FILE: MatchStatus.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------
// Defines the MatchStatus enum for fill-in brackets.

import Foundation

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MatchStatus: String, CaseIterable, Codable {
    case confirmed = "Confirmed"
    case declined  = "Declined"
    case pending   = "Pending"
}
