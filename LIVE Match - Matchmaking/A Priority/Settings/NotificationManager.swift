//
//  NotificationManager.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/3/25.
//


// MARK: - NotificationManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI
import UserNotifications

@MainActor
public class NotificationManager: ObservableObject {
    @Published public var isNotificationsEnabled: Bool = false
    
    public init() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isNotificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    public func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isNotificationsEnabled = granted
            }
        }
    }
}
