// MARK: File 22: TournamentAppApp.swift
// iOS 15.6+
// Only for iOS, we configure AdMob on launch. Not for macOS/visionOS.

import SwiftUI
import Firebase
import FirebaseAppCheck // Make sure to import this
#if canImport(UIKit)
import GoogleMobileAds
#endif

@main
@available(iOS 15.6, *)
struct TournamentAppApp: App {
    // MARK: - Init
    init() {
        print("[TournamentAppApp] init started.")
        
        // 1. Configure Firebase
        FirebaseApp.configure()
        print("[TournamentAppApp] FirebaseApp.configure() called.")
        
        // 2. Enable Debug provider for App Check (Simulator usage)
        #if canImport(UIKit)
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        print("[TournamentAppApp] AppCheckDebugProviderFactory set for simulator testing.")
        #endif
        
        // 3. Configure AdMob if on iOS
        #if canImport(UIKit)
        AdManager.shared.configureAdMob()
        print("[TournamentAppApp] AdManager.shared.configureAdMob() called.")
        #endif
        
        print("[TournamentAppApp] init completed.")
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            let _ = print("[TournamentAppApp] SplashView will be displayed in the WindowGroup.")
            SplashView()
        }
        #if os(macOS)
        Settings {
            let _ = print("[TournamentAppApp] On macOS, providing Settings scene with SettingsView.")
            SettingsView()
        }
        #endif
    }
}
