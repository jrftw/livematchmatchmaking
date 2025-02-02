//
//  AppSettingsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - AppSettingsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A cross-platform settings screen with an Add-On section, Features section,
// Appearance, Timezone, Version, Support, and a new "Force Logout" section above the footer.
// Refactored to avoid expression builder issues by returning each Section via functions.

import SwiftUI
import CoreLocation
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppSettingsView: View {
    // MARK: - AppStorage
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @AppStorage("defaultTimezone") private var defaultTimezone: String = ""
    
    // MARK: - State
    @State private var showChangelog = false
    @StateObject private var locationManager = LocationRegionDetector()
    
    // MARK: - Init
    public init() {
        let _ = print("[AppSettingsView] init called. appColorScheme: \(appColorScheme), defaultTimezone: \(defaultTimezone)")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[AppSettingsView] body invoked.")
        
        return NavigationView {
            Form {
                addOnSection()
                featuresSection()
                appearanceSection()
                timezoneSection()
                versionSection()
                supportSection()
                
                let _ = print("[AppSettingsView] Adding Force Logout section.")
                ForceLogoutSection()
                
                footerSection()
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showChangelog) {
                let _ = print("[AppSettingsView] ChangelogView sheet presented.")
                ChangelogView()
            }
            .onChange(of: appColorScheme) { newValue in
                let _ = print("[AppSettingsView] appColorScheme changed to: \(newValue). Applying color scheme.")
                applyColorScheme(newValue)
            }
            .onAppear {
                let _ = print("[AppSettingsView] onAppear => Checking defaultTimezone and applying color scheme.")
                if defaultTimezone.isEmpty {
                    detectInitialTimeZone()
                }
                applyColorScheme(appColorScheme)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Add-On Section
    private func addOnSection() -> some View {
        let _ = print("[AppSettingsView] Building Add-On section.")
        
        return Section("Add On") {
            NavigationLink("Manage Add-Ons") {
                let _ = print("[AppSettingsView] NavigationLink to AddOnsView triggered.")
                AddOnsView()
            }
        }
    }
    
    // MARK: - Features Section
    private func featuresSection() -> some View {
        let _ = print("[AppSettingsView] Building Features section.")
        
        return Section("Features") {
            let _ = print("[AppSettingsView] Toggle => 'Enable Auto-Updates' is always 'true'.")
            Toggle("Enable Auto-Updates", isOn: .constant(true))
            
            Button("Force Version Check") {
                let _ = print("[AppSettingsView] 'Force Version Check' button tapped.")
                AppVersion.validateAndForceUpdate()
            }
        }
    }
    
    // MARK: - Appearance Section
    private func appearanceSection() -> some View {
        let _ = print("[AppSettingsView] Building Appearance section.")
        
        return Section("Appearance") {
            Picker("Color Scheme", selection: $appColorScheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Timezone Section
    private func timezoneSection() -> some View {
        let _ = print("[AppSettingsView] Building Timezone section.")
        
        return Section("Timezone") {
            NavigationLink("Change Default Timezone") {
                let _ = print("[AppSettingsView] NavigationLink => TimeZonePickerView triggered.")
                TimeZonePickerView(currentSelection: $defaultTimezone)
            }
            
            Text("Current Timezone: \(defaultTimezone)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if locationManager.authorizationStatus == .notDetermined ||
               locationManager.authorizationStatus == .denied {
                Button("Enable Location Services") {
                    let _ = print("[AppSettingsView] 'Enable Location Services' button tapped.")
                    locationManager.requestLocationPermission()
                }
            }
        }
    }
    
    // MARK: - Version Section
    private func versionSection() -> some View {
        let _ = print("[AppSettingsView] Building Version section.")
        
        return Section("App Version") {
            Text(AppVersion.displayVersionString)
            Button("View Changelog") {
                let _ = print("[AppSettingsView] 'View Changelog' button tapped.")
                showChangelog = true
            }
        }
    }
    
    // MARK: - Support Section
    private func supportSection() -> some View {
        let _ = print("[AppSettingsView] Building Support section.")
        
        return Section("Support") {
            Button("Contact") {
                let _ = print("[AppSettingsView] 'Contact' button tapped. Attempting openMail.")
                openMail()
            }
            Button("Join the Discord") {
                let _ = print("[AppSettingsView] 'Join the Discord' button tapped. Attempting openDiscord.")
                openDiscord()
            }
        }
    }
    
    // MARK: - Footer Section
    private func footerSection() -> some View {
        let _ = print("[AppSettingsView] Building Footer section.")
        
        return Section {
            SettingsFooterView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .textCase(nil)
    }
    
    // MARK: - Color Scheme
    private func applyColorScheme(_ scheme: String) {
        let _ = print("[AppSettingsView] applyColorScheme(\(scheme)) called.")
        #if !os(macOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            let _ = print("[AppSettingsView] Could not retrieve UIWindowScene for color scheme override.")
            return
        }
        
        switch scheme {
        case "light":
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
            let _ = print("[AppSettingsView] UI style set to .light.")
        case "dark":
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .dark }
            let _ = print("[AppSettingsView] UI style set to .dark.")
        default:
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .unspecified }
            let _ = print("[AppSettingsView] UI style set to .unspecified (System).")
        }
        #endif
    }
    
    // MARK: - Detect or Default Timezone
    private func detectInitialTimeZone() {
        let _ = print("[AppSettingsView] detectInitialTimeZone called.")
        if let regionTZ = locationManager.detectedTimeZone {
            defaultTimezone = regionTZ
            let _ = print("[AppSettingsView] detectedTimeZone from LocationManager: \(regionTZ).")
        } else {
            let systemTZ = TimeZone.current
            defaultTimezone = systemTZ.identifier
            let _ = print("[AppSettingsView] fallback => system TimeZone: \(systemTZ.identifier).")
        }
    }
    
    // MARK: - Helpers
    private func openMail() {
        let _ = print("[AppSettingsView] openMail called.")
        #if !os(macOS)
        if let url = URL(string: "mailto:jrftw@infinitumlive.com") {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    private func openDiscord() {
        let _ = print("[AppSettingsView] openDiscord called.")
        #if !os(macOS)
        if let url = URL(string: "https://discord.gg/gJK9PH4eDR") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}
