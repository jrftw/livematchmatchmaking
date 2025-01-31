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
    init() {
        FirebaseApp.configure()
        #if canImport(UIKit)
        AdManager.shared.configureAdMob()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
