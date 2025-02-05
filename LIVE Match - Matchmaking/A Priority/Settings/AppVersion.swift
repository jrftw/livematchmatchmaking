//
//  AppVersion.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//
// MARK: File: AppVersion.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Stores the current app version and build number, and can enforce a required version check.

import Foundation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppVersion {
    // MARK: - Static Version & Build
    public static let currentVersion: String = "1.0"
    public static let currentBuild: String = "8"
    
    private static let requiredVersion: String = "1.0"
    private static let requiredBuild: String = "8"
    
    // MARK: - isVersionValid
    // Ensures the user is on at least the requiredVersion/Build
    public static func isVersionValid() -> Bool {
        print("[AppVersion] isVersionValid called.")
        print("[AppVersion] currentVersion: \(currentVersion), currentBuild: \(currentBuild), requiredVersion: \(requiredVersion), requiredBuild: \(requiredBuild)")
        
        guard currentVersion == requiredVersion, currentBuild >= requiredBuild else {
            print("[AppVersion] Version check failed. User must update.")
            return false
        }
        
        print("[AppVersion] Version check passed.")
        return true
    }
    
    // MARK: - displayVersionString
    public static var displayVersionString: String {
        let _ = print("[AppVersion] displayVersionString computed.")
        return "Version \(currentVersion) (\(currentBuild))"
    }
    
    // MARK: - validateAndForceUpdate
    public static func validateAndForceUpdate() {
        print("[AppVersion] validateAndForceUpdate called.")
        
        if !isVersionValid() {
            print("[AppVersion] User must update to at least Version \(requiredVersion) (Build \(requiredBuild)).")
            // In a real-world scenario, present an update flow or direct to the App Store here.
        } else {
            print("[AppVersion] No update required. User is on a valid version.")
        }
    }
}
