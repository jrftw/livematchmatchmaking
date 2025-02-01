//
//  AppVersion.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  AppVersion.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: AppVersion.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Stores the current app version and build number, and can enforce a required version check.

import Foundation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppVersion {
    public static let currentVersion: String = "1.0"
    public static let currentBuild: String = "4"
    
    // If you want to require the user to be on at least version 1.0 (build 1), set requiredVersion below:
    // For a real-world scenario, you might fetch this from a remote config or your backend.
    private static let requiredVersion: String = "1.0"
    private static let requiredBuild: String = "4"
    
    // MARK: checkVersion
    // Ensures the user is on at least the requiredVersion/Build
    // Return 'true' if valid, 'false' if user must update.
    public static func isVersionValid() -> Bool {
        // Simple string comparison for demonstration. In production, you might parse into major/minor/patch integers.
        guard currentVersion == requiredVersion, currentBuild >= requiredBuild else {
            return false
        }
        return true
    }
    
    // MARK: displayVersionString
    public static var displayVersionString: String {
        // e.g. "Version 1.0 (1)"
        "Version \(currentVersion) (\(currentBuild))"
    }
    
    // MARK: validateAndForceUpdate
    // If user is on an older version, present an update requirement (placeholder).
    public static func validateAndForceUpdate() {
        if !isVersionValid() {
            // For demonstration. In a real scenario, you might present an alert or direct to the App Store.
            print("User must update to at least Version \(requiredVersion) (Build \(requiredBuild)).")
        }
    }
}
