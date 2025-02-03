// MARK: - ProfileNavigationService.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI

public final class ProfileNavigationService: ObservableObject {
    public static let shared = ProfileNavigationService()
    private init() {}
    
    @Published public var selectedUserId: String? = nil
    
    public func showProfile(userId: String) {
        selectedUserId = userId
    }
}
