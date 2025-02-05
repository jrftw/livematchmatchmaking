//
//  AchievementsManager.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//
// MARK: - AchievementsManager.swift
// Manages and tracks all achievements, including daily login streaks,
// storing them in Firestore for leaderboards and awarding "Daily Login" only once per day.

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public class AchievementsManager: ObservableObject {
    // MARK: - Published Properties
    @Published public var username: String = "Unknown"
    @Published public var totalScore: Int = 0
    @Published public var loginStreak: Int = 0
    @Published public var achievements: [Achievement] = []
    
    // MARK: - Last Login
    private var lastLoginDate: Date?
    
    // MARK: - Track whether today's Daily Login has been claimed
    private var lastDailyClaimedDate: Date?
    
    // MARK: - Local Persistence Keys
    private let lastLoginDateKey       = "lastLoginDate"
    private let lastDailyClaimedKey    = "lastDailyClaimedDate"
    private let loginStreakKey         = "loginStreak"
    private let totalScoreKey          = "totalScore"
    private let achievementsKey        = "achievementsList"
    
    // MARK: - Init
    public init() {
        loadUsernameFromFirestore()
        loadDefaultAchievements()
        loadLocalData()
    }
    
    // MARK: - Load Username from Firestore
    private func loadUsernameFromFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            self.username = "Guest"
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] snap, error in
            guard let self = self else { return }
            if let error = error {
                print("[AchievementsManager] Firestore error: \(error.localizedDescription)")
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
                return
            }
            
            guard let data = snap?.data(), !data.isEmpty else {
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
        if achievements.isEmpty {
            let dailyLogin = Achievement(
                id: "daily_login",
                name: "Daily Login",
                description: "Earn 5 points once each day you log in.",
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
            
            achievements = [dailyLogin] + streakMilestones + [
                inviteFriend,
                win10Matches,
                completeProfile
            ]
        }
    }
    
    // MARK: - Daily Login
    // Award "daily_login" achievement only once per day (not every app launch).
    public func registerDailyLogin() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Update login streak
        if let lastLogin = lastLoginDate {
            let lastLoginStart = Calendar.current.startOfDay(for: lastLogin)
            let diff = Calendar.current.dateComponents([.day], from: lastLoginStart, to: today).day ?? 0
            if diff == 1 {
                loginStreak += 1
            } else if diff > 1 {
                // Missed a day => reset streak
                loginStreak = 1
            }
        } else {
            // First login
            loginStreak = 1
        }
        lastLoginDate = today
        
        // Claim daily_login only if we haven't claimed it yet today
        if let dailyIdx = achievements.firstIndex(where: { $0.id == "daily_login" }) {
            // Check if we've already claimed today
            if let lastClaimed = lastDailyClaimedDate {
                // Compare day components
                let lastClaimedStart = Calendar.current.startOfDay(for: lastClaimed)
                if lastClaimedStart == today {
                    print("[AchievementsManager] Already claimed Daily Login today.")
                } else {
                    claimDailyLogin(at: dailyIdx)
                }
            } else {
                // No record => claim
                claimDailyLogin(at: dailyIdx)
            }
        }
        
        awardStreakAchievementsIfNeeded()
        saveLocalData()
        saveDataToFirestore()
    }
    
    private func claimDailyLogin(at index: Int) {
        achievements[index].currentProgress = 1
        achievements[index].isUnlocked = true
        totalScore += achievements[index].points
        lastDailyClaimedDate = Date()
        
        print("[AchievementsManager] Daily login => +\(achievements[index].points), totalScore=\(totalScore).")
    }
    
    // MARK: - Award Streak Achievements
    private func awardStreakAchievementsIfNeeded() {
        for i in 0..<achievements.count {
            if achievements[i].id.contains("streak_") && !achievements[i].isUnlocked {
                if loginStreak >= achievements[i].requiredProgress {
                    achievements[i].currentProgress = achievements[i].requiredProgress
                    achievements[i].isUnlocked = true
                    totalScore += achievements[i].points
                    print("[AchievementsManager] Unlocked streak \(achievements[i].name) => +\(achievements[i].points). totalScore=\(totalScore)")
                }
            }
        }
        saveLocalData()
        saveDataToFirestore()
    }
    
    // MARK: - Update Achievement
    public func updateAchievementProgress(id: String, increment: Int = 1) {
        if let idx = achievements.firstIndex(where: { $0.id == id }) {
            achievements[idx].currentProgress += increment
            
            if achievements[idx].currentProgress >= achievements[idx].requiredProgress &&
               !achievements[idx].isUnlocked {
                achievements[idx].isUnlocked = true
                totalScore += achievements[idx].points
                print("[AchievementsManager] '\(achievements[idx].name)' => +\(achievements[idx].points). totalScore=\(totalScore)")
            }
            saveLocalData()
            saveDataToFirestore()
        }
    }
    
    // MARK: - Save to Firestore
    private func saveDataToFirestore() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)
        
        let data: [String: Any] = [
            "username": self.username,
            "totalScore": self.totalScore,
            "loginStreak": self.loginStreak
        ]
        
        docRef.setData(data, merge: true) { err in
            if let err = err {
                print("[AchievementsManager] Firestore save error: \(err.localizedDescription)")
            } else {
                print("[AchievementsManager] Synced score (\(self.totalScore)) + streak (\(self.loginStreak)) to Firestore.")
            }
        }
    }
    
    // MARK: - Load from UserDefaults
    private func loadLocalData() {
        let defaults = UserDefaults.standard
        
        // lastLoginDate
        if let savedTime = defaults.object(forKey: lastLoginDateKey) as? TimeInterval {
            lastLoginDate = Date(timeIntervalSince1970: savedTime)
        }
        // lastDailyClaimedDate
        if let savedDaily = defaults.object(forKey: lastDailyClaimedKey) as? TimeInterval {
            lastDailyClaimedDate = Date(timeIntervalSince1970: savedDaily)
        }
        
        loginStreak = defaults.integer(forKey: loginStreakKey)
        totalScore  = defaults.integer(forKey: totalScoreKey)
        
        if let storedData = defaults.data(forKey: achievementsKey) {
            do {
                let decoder = JSONDecoder()
                achievements = try decoder.decode([Achievement].self, from: storedData)
            } catch {
                print("[AchievementsManager] Error decoding achievements: \(error)")
            }
        }
    }
    
    // MARK: - Save to UserDefaults
    private func saveLocalData() {
        let defaults = UserDefaults.standard
        
        if let lastLoginDate = lastLoginDate {
            defaults.set(lastLoginDate.timeIntervalSince1970, forKey: lastLoginDateKey)
        }
        if let lastDailyClaimedDate = lastDailyClaimedDate {
            defaults.set(lastDailyClaimedDate.timeIntervalSince1970, forKey: lastDailyClaimedKey)
        }
        
        defaults.set(loginStreak, forKey: loginStreakKey)
        defaults.set(totalScore, forKey: totalScoreKey)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(achievements)
            defaults.set(data, forKey: achievementsKey)
        } catch {
            print("[AchievementsManager] Error encoding achievements: \(error)")
        }
    }
}
