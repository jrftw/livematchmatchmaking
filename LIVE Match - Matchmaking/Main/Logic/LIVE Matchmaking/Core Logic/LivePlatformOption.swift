//
//  LivePlatformOption.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A single source of truth for platforms (TikTok, YouTube, etc.).
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LivePlatformOption: Identifiable {
    public let id = UUID()
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
