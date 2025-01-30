// MARK: File: LivePlatformOption.swift
// Make this public so it can be used by public properties or initializers in other modules.

import Foundation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LivePlatformOption: Identifiable {
    public let id = UUID()
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
