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
import FirebaseMessaging
import UserNotifications

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
            SplashView() // Your main SwiftUI entry view.
                .onAppear {
                    requestNotificationAuthorization()
                }
        }
    }
    
    // MARK: - Notification Authorization
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[Notifications] Error requesting authorization: \(error.localizedDescription)")
            } else {
                print("[Notifications] Permission granted? \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
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
        
        // 3. Configure Crashlytics and Analytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [
            "source": "didFinishLaunchingWithOptions" as NSObject
        ])
        print("[AppDelegate] Crashlytics and Analytics have been configured.")
        
        // 4. Configure AdMob (for iOS)
        #if canImport(UIKit)
        AdManager.shared.configureAdMob()
        print("[AppDelegate] AdManager.shared.configureAdMob() called.")
        #endif
        
        // 5. Set up Firebase Messaging
        Messaging.messaging().delegate = self
        
        // 6. Set the UNUserNotificationCenter delegate to self
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - Push Notifications
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("[AppDelegate] Registered for remote notifications.")
        // If using Firebase Cloud Messaging:
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("[AppDelegate] FCM registration token refreshed: \(fcmToken ?? "")")
        // TODO: If needed, send this token to your server or save it
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    // In-app display for iOS 14+ or iOS 10+ with UNUserNotificationCenter
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Display the notification while the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Called when a notification is tapped or action is taken
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[AppDelegate] User tapped notification: \(userInfo)")
        completionHandler()
    }
}
