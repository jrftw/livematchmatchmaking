// MARK: File 22: TournamentAppApp.swift
// iOS 15.6+
// Only for iOS, we configure AdMob on launch. Not for macOS/visionOS.

import SwiftUI
import Firebase
#if canImport(UIKit)
import GoogleMobileAds
#endif

@main
@available(iOS 15.6, *)
struct TournamentAppApp: App {
    // MARK: - Init
    init() {
        print("[TournamentAppApp] init started.")
        
        FirebaseApp.configure()
        print("[TournamentAppApp] FirebaseApp.configure() called.")
        
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
