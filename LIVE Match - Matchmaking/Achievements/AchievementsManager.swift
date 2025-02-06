// MARK: - AchievementsManager.swift
// Manages and tracks all achievements, including daily login streaks,
// storing them in Firestore for leaderboards and awarding "Daily Login" only once per day.
// Includes extensive logging in debugLogs (printed to console, not shown in UI).

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
    
    // Debug logs are now internal, not displayed in UI. For console debugging only.
    private var debugLogs: [String] = []
    
    // MARK: - Keys for Local Persistence
    private let lastLoginDateKey    = "lastLoginDate"
    private let lastDailyClaimedKey = "lastDailyClaimedDate"
    private let loginStreakKey      = "loginStreak"
    private let totalScoreKey       = "totalScore"
    private let achievementsKey     = "achievementsList"
    
    // MARK: - Internal State
    private var lastLoginDate: Date?
    private var lastDailyClaimedDate: Date?
    
    // MARK: - Init
    public init() {
        log("Initializing AchievementsManager")
        loadUsernameFromFirestore()
        loadDefaultAchievements()
        loadLocalData()
    }
    
    // MARK: - Logging Helper
    private func log(_ message: String) {
        let entry = "[\(Date())] \(message)"
        debugLogs.append(entry)
        print(entry) // Printed to console only
    }
    
    // MARK: - Load Username from Firestore
    private func loadUsernameFromFirestore() {
        guard let currentUser = Auth.auth().currentUser else {
            self.username = "Guest"
            log("No currentUser found; defaulting username to Guest")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] snap, error in
            guard let self = self else { return }
            
            if let error = error {
                self.log("Firestore error loading username: \(error.localizedDescription)")
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
                return
            }
            
            guard let data = snap?.data(), !data.isEmpty else {
                self.log("No Firestore data found for user => using displayName/email as fallback")
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
                return
            }
            
            if let storedUsername = data["username"] as? String, !storedUsername.isEmpty {
                self.username = storedUsername
                self.log("Loaded username from Firestore: \(storedUsername)")
            } else {
                self.username = currentUser.displayName ?? currentUser.email ?? "LiveMatchUser"
                self.log("No 'username' field => using displayName/email: \(self.username)")
            }
        }
    }
    
    // MARK: - Load Default Achievements
    private func loadDefaultAchievements() {
        log("Checking if achievements array is empty...")
        guard achievements.isEmpty else {
            log("Achievements already loaded; skipping default creation.")
            return
        }
        
        log("No achievements found; creating defaults with unique IDs.")
        
        let dailyLogin = Achievement(
            id: "com.livematch.achievements.daily_login",
            name: "Daily Login",
            description: "Earn 5 points once each day you log in.",
            points: 5,
            requiredProgress: 1,
            currentProgress: 0,
            isUnlocked: false
        )
        
        let streakMilestones = [3, 7, 10, 13, 15, 20, 40, 50, 100, 200, 365].map {
            Achievement(
                id: "com.livematch.achievements.streak_\($0)",
                name: "Login Streak: \($0) days",
                description: "Keep logging in consecutively for \($0) days to earn 10 points.",
                points: 10,
                requiredProgress: $0,
                currentProgress: 0,
                isUnlocked: false
            )
        }
        
        let inviteFriend = Achievement(
            id: "com.livematch.achievements.invite_friend",
            name: "Invite a Friend",
            description: "Invite at least 1 friend to earn 10 points.",
            points: 10,
            requiredProgress: 1,
            currentProgress: 0,
            isUnlocked: false
        )
        
        let win10Matches = Achievement(
            id: "com.livematch.achievements.win_10_matches",
            name: "Champion!",
            description: "Win 10 matches to earn 20 points.",
            points: 20,
            requiredProgress: 10,
            currentProgress: 0,
            isUnlocked: false
        )
        
        let completeProfile = Achievement(
            id: "com.livematch.achievements.complete_profile",
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
        
        log("Default achievements created: \(achievements.count) total.")
    }
    
    // MARK: - Support Adding Future Achievements
    public func addNewAchievement(_ achievement: Achievement) {
        log("Attempting to add new achievement with ID: \(achievement.id)")
        if !achievements.contains(where: { $0.id == achievement.id }) {
            achievements.append(achievement)
            log("New achievement added: \(achievement.name) (ID: \(achievement.id))")
            saveLocalData()
        } else {
            log("Achievement with ID '\(achievement.id)' already exists; skipping.")
        }
    }
    
    // MARK: - Daily Login
    public func registerDailyLogin() {
        log("Registering daily login attempt.")
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastLogin = lastLoginDate {
            let lastLoginStart = Calendar.current.startOfDay(for: lastLogin)
            let diff = Calendar.current.dateComponents([.day], from: lastLoginStart, to: today).day ?? 0
            
            if diff == 1 {
                loginStreak += 1
                log("Streak incremented by 1 => new streak: \(loginStreak)")
            } else if diff > 1 {
                loginStreak = 1
                log("Streak reset => new streak: 1")
            } else {
                log("No day difference => streak remains: \(loginStreak)")
            }
        } else {
            loginStreak = 1
            log("First login => streak set to 1")
        }
        
        lastLoginDate = today
        
        // Update partial progress on all streak achievements
        updatePartialStreakProgress()
        
        // Now check if daily login achievement can be claimed
        if let dailyIdx = achievements.firstIndex(where: { $0.id == "com.livematch.achievements.daily_login" }) {
            if let lastClaimed = lastDailyClaimedDate {
                let lastClaimedStart = Calendar.current.startOfDay(for: lastClaimed)
                
                if lastClaimedStart == today {
                    log("Already claimed daily login for today.")
                } else {
                    claimDailyLogin(at: dailyIdx)
                }
            } else {
                claimDailyLogin(at: dailyIdx)
            }
        } else {
            log("No daily_login achievement found.")
        }
        
        // Award any streak achievements that are now complete
        awardStreakAchievementsIfNeeded()
        saveLocalData()
        saveDataToFirestore()
    }
    
    private func claimDailyLogin(at index: Int) {
        achievements[index].currentProgress = 1
        achievements[index].isUnlocked = true
        totalScore += achievements[index].points
        lastDailyClaimedDate = Date()
        
        log("Claimed 'Daily Login' => +\(achievements[index].points) points, totalScore=\(totalScore)")
    }
    
    // MARK: - Update Partial Streak Progress
    private func updatePartialStreakProgress() {
        log("Updating partial streak progress to match current loginStreak = \(loginStreak).")
        for i in 0..<achievements.count {
            if achievements[i].id.contains("streak_") {
                // If not unlocked, show partial progress = min(loginStreak, requiredProgress)
                if !achievements[i].isUnlocked {
                    let partial = min(loginStreak, achievements[i].requiredProgress)
                    achievements[i].currentProgress = partial
                    log("Setting partial streak progress for \(achievements[i].name) => \(partial)/\(achievements[i].requiredProgress)")
                } else {
                    // If unlocked, keep it at requiredProgress
                    achievements[i].currentProgress = achievements[i].requiredProgress
                }
            }
        }
    }
    
    // MARK: - Award Streak Achievements
    private func awardStreakAchievementsIfNeeded() {
        log("Checking for streak achievements to award after partial progress update.")
        
        for i in 0..<achievements.count {
            let ach = achievements[i]
            guard ach.id.contains("streak_"), !ach.isUnlocked else { continue }
            
            if loginStreak >= ach.requiredProgress {
                achievements[i].currentProgress = ach.requiredProgress
                achievements[i].isUnlocked = true
                totalScore += ach.points
                log("Unlocked streak: \(ach.name) => +\(ach.points) points, totalScore=\(totalScore)")
            }
        }
    }
    
    // MARK: - Update Achievement
    public func updateAchievementProgress(id: String, increment: Int = 1) {
        log("Attempting to update achievement progress for ID: \(id) by +\(increment).")
        
        if let idx = achievements.firstIndex(where: { $0.id == id }) {
            achievements[idx].currentProgress += increment
            let ach = achievements[idx]
            
            log("Achievement '\(ach.name)' progress => \(ach.currentProgress)/\(ach.requiredProgress).")
            
            if ach.currentProgress >= ach.requiredProgress && !ach.isUnlocked {
                achievements[idx].isUnlocked = true
                totalScore += ach.points
                log("Achievement '\(ach.name)' is now UNLOCKED => +\(ach.points) points, totalScore=\(totalScore)")
            }
            saveLocalData()
            saveDataToFirestore()
        } else {
            log("No achievement found with ID: \(id). Unable to update progress.")
        }
    }
    
    // MARK: - Save to Firestore
    private func saveDataToFirestore() {
        log("Saving achievements data to Firestore.")
        guard let user = Auth.auth().currentUser else {
            log("No user signed in => skipping Firestore save.")
            return
        }
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)
        
        let data: [String: Any] = [
            "username": self.username,
            "totalScore": self.totalScore,
            "loginStreak": self.loginStreak
        ]
        
        docRef.setData(data, merge: true) { err in
            if let err = err {
                self.log("Firestore save error: \(err.localizedDescription)")
            } else {
                self.log("Synced to Firestore => score: \(self.totalScore), streak: \(self.loginStreak).")
            }
        }
    }
    
    // MARK: - Load from UserDefaults
    private func loadLocalData() {
        log("Loading local achievements data from UserDefaults.")
        
        let defaults = UserDefaults.standard
        
        if let savedTime = defaults.object(forKey: lastLoginDateKey) as? TimeInterval {
            lastLoginDate = Date(timeIntervalSince1970: savedTime)
            log("Loaded lastLoginDate: \(String(describing: lastLoginDate))")
        }
        if let savedDaily = defaults.object(forKey: lastDailyClaimedKey) as? TimeInterval {
            lastDailyClaimedDate = Date(timeIntervalSince1970: savedDaily)
            log("Loaded lastDailyClaimedDate: \(String(describing: lastDailyClaimedDate))")
        }
        
        loginStreak = defaults.integer(forKey: loginStreakKey)
        totalScore  = defaults.integer(forKey: totalScoreKey)
        log("Loaded loginStreak: \(loginStreak), totalScore: \(totalScore)")
        
        if let storedData = defaults.data(forKey: achievementsKey) {
            do {
                let decoder = JSONDecoder()
                achievements = try decoder.decode([Achievement].self, from: storedData)
                log("Decoded achievements from local storage => count: \(achievements.count)")
            } catch {
                log("Error decoding achievements: \(error.localizedDescription)")
            }
        } else {
            log("No local achievements data found.")
        }
    }
    
    // MARK: - Save to UserDefaults
    private func saveLocalData() {
        log("Saving achievements data locally to UserDefaults.")
        
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
            log("Successfully saved achievements to UserDefaults.")
        } catch {
            log("Error encoding achievements: \(error.localizedDescription)")
        }
    }
}
