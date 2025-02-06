// MARK: LIVE_Match___MatchmakingApp.swift

#if canImport(UIKit)
import SwiftUI
import Firebase
import FirebaseAppCheck
import FirebaseMessaging
import UserNotifications

// 1. Import AppTrackingTransparency and AdSupport to handle IDFA & ATT
import AppTrackingTransparency
import AdSupport

@main
struct LIVE_Match___MatchmakingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        print("[LIVE_Match___MatchmakingApp] init started on iOS.")
        print("[LIVE_Match___MatchmakingApp] init completed on iOS.")
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .onAppear {
                    // 2. Request ATT & push notification authorization on first launch.
                    //    iOS automatically prevents re-prompting if the user has already made a choice.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        requestAppTrackingTransparency()
                        requestNotificationAuthorization()
                    }
                }
        }
    }

    // MARK: - ATT Prompt
    private func requestAppTrackingTransparency() {
        // If iOS 14 or later is available
        if #available(iOS 14, *) {
            // If user hasn’t responded before, iOS will show the prompt.
            // If the user already denied or allowed, calling this again does nothing visible.
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    print("[ATT] User has not been prompted yet or is still deciding.")
                case .restricted:
                    print("[ATT] Tracking restricted (e.g., parental controls).")
                case .denied:
                    print("[ATT] User denied tracking request.")
                case .authorized:
                    print("[ATT] User granted tracking authorization.")
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("[ATT] IDFA: \(idfa)")
                @unknown default:
                    break
                }
            }
        } else {
            print("[ATT] iOS < 14 => IDFA used without ATT prompt.")
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
        print("[AppDelegate] didFinishLaunchingWithOptions called on iOS.")
        
        // Configure Firebase
        FirebaseApp.configure()
        print("[AppDelegate] FirebaseApp.configure() done on iOS.")
        
        #if targetEnvironment(simulator)
        // Use Debug App Check in the simulator
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        AppCheck.appCheck().isTokenAutoRefreshEnabled = true
        print("[AppDelegate] AppCheckDebugProviderFactory set for simulator + autoRefresh enabled on iOS.")
        #endif
        
        // Configure Crashlytics & Analytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: ["source": "didFinishLaunchingWithOptions" as NSObject])
        
        // Configure AdMob
        AdManager.shared.configureAdMob()
        
        // Firebase Messaging & Notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - APNS Register
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("[AppDelegate] Registered for remote notifications on iOS.")
        Messaging.messaging().apnsToken = deviceToken
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        print("[LIVE_Match___MatchmakingApp] init started on macOS.")
        print("[LIVE_Match___MatchmakingApp] init completed on macOS.")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .onAppear {
                    requestNotificationAuthorization()
                }
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[Notifications] Error requesting authorization on macOS: \(error.localizedDescription)")
            } else {
                print("[Notifications] Permission granted on macOS? \(granted)")
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
        
        #if targetEnvironment(simulator)
        // Use Debug App Check in the simulator
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        AppCheck.appCheck().isTokenAutoRefreshEnabled = true
        print("[AppDelegate] AppCheckDebugProviderFactory set for simulator + autoRefresh enabled on macOS.")
        #endif
        
        // Crashlytics & Analytics
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: ["source": "applicationDidFinishLaunching" as NSObject])
        
        // AdMob
        AdManager.shared.configureAdMob()
        
        // Messaging & Notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("[AppDelegate] FCM registration token refreshed on macOS: \(fcmToken ?? "")")
    }
    
    // macOS notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
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
