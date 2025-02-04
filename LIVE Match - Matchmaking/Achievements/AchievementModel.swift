//
//  AchievementsModel.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//
// MARK: - AchievementsModel.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Manages and tracks all achievements, including daily login streaks.

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - Achievement Data Model
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Achievement: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let points: Int
    public let requiredProgress: Int
    public var currentProgress: Int
    public var isUnlocked: Bool
}

// MARK: - Achievements Manager
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public class AchievementsManager: ObservableObject {
    // MARK: - Published Properties
    @Published public var username: String = "Unknown"
    @Published public var totalScore: Int  = 0
    @Published public var achievements: [Achievement] = []
    @Published public var loginStreak: Int = 0
    
    // MARK: - Tracking
    private var lastLoginDate: Date?

    // MARK: - Init
    public init() {
        loadUsernameFromFirestore()
        loadDefaultAchievements()
    }
    
    // MARK: - Load Username from Firestore
    //
    // Assumes you have a "users" collection,
    // where each document is named by the user's UID,
    // containing a field "username".
    //
    // If "username" is missing, it falls back to displayName/email.
    private func loadUsernameFromFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            self.username = "Guest"
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[AchievementsManager] Firestore error: \(error.localizedDescription)")
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
                return
            }
            
            guard let data = snapshot?.data(), !data.isEmpty else {
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
                return
            }
            
            if let storedUsername = data["username"] as? String, !storedUsername.isEmpty {
                self.username = storedUsername
            } else {
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
            }
        }
    }
    
    // MARK: - Load Default Achievements
    private func loadDefaultAchievements() {
        let dailyLoginAchievement = Achievement(
            id: "daily_login",
            name: "Daily Login",
            description: "Earn 5 points for logging in each day.",
            points: 5,
            requiredProgress: 1,
            currentProgress: 0,
            isUnlocked: false
        )
        
        let streakMilestones = [3, 7, 10, 13, 15, 20, 40, 50, 100, 200, 365].map {
            Achievement(
                id: "streak_\($0)",
                name: "Login Streak: \($0) days",
                description: "Keep logging in consecutively for \($0) days to earn 10 points.",
                points: 10,
                requiredProgress: $0,
                currentProgress: 0,
                isUnlocked: false
            )
        }
        
        let inviteFriend = Achievement(
            id: "invite_friend",
            name: "Invite a Friend",
            description: "Invite at least 1 friend to earn 10 points.",
            points: 10,
            requiredProgress: 1,
            currentProgress: 0,
            isUnlocked: false
        )
        
        let win10Matches = Achievement(
            id: "win_10_matches",
            name: "Champion!",
            description: "Win 10 matches to earn 20 points.",
            points: 20,
            requiredProgress: 10,
            currentProgress: 0,
            isUnlocked: false
        )
        
        let completeProfile = Achievement(
            id: "complete_profile",
            name: "Profile Complete",
            description: "Complete your profile to earn 5 points.",
            points: 5,
            requiredProgress: 1,
            currentProgress: 0,
            isUnlocked: false
        )
        
        achievements = [dailyLoginAchievement] + streakMilestones + [
            inviteFriend,
            win10Matches,
            completeProfile
        ]
    }
    
    // MARK: - Daily Login / Streak
    public func registerDailyLogin() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastLogin = lastLoginDate {
            let lastLoginStart = Calendar.current.startOfDay(for: lastLogin)
            let diff = Calendar.current.dateComponents([.day], from: lastLoginStart, to: today).day ?? 0
            if diff == 1 {
                loginStreak += 1
            } else if diff > 1 {
                loginStreak = 1
            }
        } else {
            loginStreak = 1
        }
        
        lastLoginDate = today
        
        if let dailyIndex = achievements.firstIndex(where: { $0.id == "daily_login" }) {
            if achievements[dailyIndex].currentProgress == 0 {
                achievements[dailyIndex].currentProgress = 1
                achievements[dailyIndex].isUnlocked = true
                totalScore += achievements[dailyIndex].points
                awardStreakAchievementsIfNeeded()
                print("[AchievementsManager] Daily login awarded +\(achievements[dailyIndex].points) points. Total = \(totalScore).")
            } else {
                print("[AchievementsManager] Daily login already claimed for today.")
            }
        }
    }
    
    // MARK: - Streak Achievements
    private func awardStreakAchievementsIfNeeded() {
        for i in 0..<achievements.count {
            if achievements[i].id.contains("streak_") && !achievements[i].isUnlocked {
                if loginStreak >= achievements[i].requiredProgress {
                    achievements[i].currentProgress = achievements[i].requiredProgress
                    achievements[i].isUnlocked = true
                    totalScore += achievements[i].points
                    print("[AchievementsManager] Streak '\(achievements[i].name)' unlocked. +\(achievements[i].points) points. Total = \(totalScore).")
                }
            }
        }
    }
    
    // MARK: - Additional Achievements
    public func updateAchievementProgress(id: String, increment: Int = 1) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].currentProgress += increment
            if achievements[index].currentProgress >= achievements[index].requiredProgress && !achievements[index].isUnlocked {
                achievements[index].isUnlocked = true
                totalScore += achievements[index].points
                print("[AchievementsManager] '\(achievements[index].name)' unlocked. +\(achievements[index].points) points. Total = \(totalScore).")
            }
        }
    }
}
