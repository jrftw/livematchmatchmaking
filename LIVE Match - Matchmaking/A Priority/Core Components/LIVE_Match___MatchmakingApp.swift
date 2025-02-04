//
//  LIVE_Match___MatchmakingApp.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+
//  The single "main" entry for your SwiftUI app, including the AppDelegate for iOS tasks.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct LIVE_Match___MatchmakingApp: App {
    // MARK: - AppDelegate for iOS Lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Init
    init() {
        print("[LIVE_Match___MatchmakingApp] init started.")
        // Any additional SwiftUI-level initialization can happen here.
        print("[LIVE_Match___MatchmakingApp] init completed.")
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            SplashView()  // Your main SwiftUI entry view.
        }
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // Called on app startup
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("[AppDelegate] didFinishLaunchingWithOptions called.")
        
        // 1. Configure Firebase
        FirebaseApp.configure()
        print("[AppDelegate] FirebaseApp.configure() done.")
        
        // 2. App Check Debug Provider for Simulator
        #if targetEnvironment(simulator)
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        // Optionally enable auto-refresh for debug tokens
        AppCheck.appCheck().isTokenAutoRefreshEnabled = true
        
        print("[AppDelegate] AppCheckDebugProviderFactory set for simulator + autoRefresh enabled.")
        #endif
        
        // 3. Additional setup if needed (e.g., Crashlytics, Analytics):
        //    Crashlytics.crashlytics()...
        //    Analytics.logEvent(...)

        // 4. Configure AdMob (for iOS)
        #if canImport(UIKit)
        AdManager.shared.configureAdMob()
        print("[AppDelegate] AdManager.shared.configureAdMob() called.")
        #endif
        
        return true
    }
    
    // MARK: - Push Notifications (Optional)
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("[AppDelegate] Registered for remote notifications.")
        // If using Firebase Cloud Messaging:
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
