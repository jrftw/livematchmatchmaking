// MARK: TimeRange.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// A public type for "TimeRange" so it can be used by public structs in your library.

import Foundation

public struct TimeRange: Identifiable, Codable {
    public var id: UUID
    public var start: Date
    public var end: Date
    
    public init(
        id: UUID = UUID(),
        start: Date = Date(),
        end: Date = Date().addingTimeInterval(3600)
    ) {
        self.id = id
        self.start = start
        self.end = end
    }
}
