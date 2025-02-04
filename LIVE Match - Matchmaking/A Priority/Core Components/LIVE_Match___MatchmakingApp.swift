#if canImport(UIKit)
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
        print("[LIVE_Match___MatchmakingApp] init started on iOS.")
        print("[LIVE_Match___MatchmakingApp] init completed on iOS.")
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("[AppDelegate] didFinishLaunchingWithOptions called on iOS.")
        
        // Configure Firebase
        FirebaseApp.configure()
        print("[AppDelegate] FirebaseApp.configure() done on iOS.")
        
        // App Check Debug Provider for Simulator
        #if targetEnvironment(simulator)
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        AppCheck.appCheck().isTokenAutoRefreshEnabled = true
        print("[AppDelegate] AppCheckDebugProviderFactory set for simulator + autoRefresh enabled on iOS.")
        #endif
        
        // Configure Crashlytics and Analytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: ["source": "didFinishLaunchingWithOptions" as NSObject])
        print("[AppDelegate] Crashlytics and Analytics configured on iOS.")
        
        // Configure AdMob
        AdManager.shared.configureAdMob()
        print("[AppDelegate] AdManager.shared.configureAdMob() called on iOS.")
        
        // Set up Firebase Messaging and notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("[AppDelegate] Registered for remote notifications on iOS.")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] Failed to register for remote notifications on iOS: \(error.localizedDescription)")
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("[AppDelegate] FCM registration token refreshed on iOS: \(fcmToken ?? "")")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[AppDelegate] User tapped notification on iOS: \(userInfo)")
        completionHandler()
    }
}

#elseif canImport(AppKit)
import SwiftUI
import Firebase
import FirebaseAppCheck
import FirebaseMessaging
import UserNotifications
import AppKit

@main
struct LIVE_Match___MatchmakingApp: App {
    // MARK: - AppDelegate for macOS Lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Init
    init() {
        print("[LIVE_Match___MatchmakingApp] init started on macOS.")
        print("[LIVE_Match___MatchmakingApp] init completed on macOS.")
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
                print("[Notifications] Error requesting authorization on macOS: \(error.localizedDescription)")
            } else {
                print("[Notifications] Permission granted on macOS? \(granted)")
                // macOS does not use UIApplication for remote notifications.
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[AppDelegate] applicationDidFinishLaunching called on macOS.")
        
        // Configure Firebase
        FirebaseApp.configure()
        print("[AppDelegate] FirebaseApp.configure() done on macOS.")
        
        // App Check Debug Provider for Simulator
        #if targetEnvironment(simulator)
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        AppCheck.appCheck().isTokenAutoRefreshEnabled = true
        print("[AppDelegate] AppCheckDebugProviderFactory set for simulator + autoRefresh enabled on macOS.")
        #endif
        
        // Configure Crashlytics and Analytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: ["source": "applicationDidFinishLaunching" as NSObject])
        print("[AppDelegate] Crashlytics and Analytics configured on macOS.")
        
        // Configure AdMob if applicable on macOS
        AdManager.shared.configureAdMob()
        print("[AppDelegate] AdManager.shared.configureAdMob() called on macOS.")
        
        // Set up Firebase Messaging and notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("[AppDelegate] FCM registration token refreshed on macOS: \(fcmToken ?? "")")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[AppDelegate] User tapped notification on macOS: \(userInfo)")
        completionHandler()
    }
}
#endif
