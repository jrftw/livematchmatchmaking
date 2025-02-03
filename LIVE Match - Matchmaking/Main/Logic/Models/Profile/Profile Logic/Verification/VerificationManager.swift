// MARK: - VerificationManager.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+

import SwiftUI
import Firebase

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public class VerificationManager: ObservableObject {
    @Published public var verifiedUsers: Set<String> = []
    
    public init() {}
    
    public func loadPreVerified() {
        verifiedUsers = ["jrftw", "infinitum_US"]
    }
    
    public func isUserVerified(username: String) -> Bool {
        verifiedUsers.contains(username.lowercased())
    }
    
    public func requestVerification(for username: String, colorChoice: Color) {
        print("Verification requested for: \(username), color: \(colorChoice)")
    }
}
