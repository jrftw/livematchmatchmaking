//
//  AchievementModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//
// MARK: - AchievementModel.swift
// Defines the Achievement struct for storing achievement data.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Achievement: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let points: Int
    public let requiredProgress: Int
    public var currentProgress: Int
    public var isUnlocked: Bool
}
