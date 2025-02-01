//
//  AppSettingsView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A cross-platform settings screen that includes appearance, default timezone, version, etc.
//  Now has an "Add On" section above "Features" to navigate to `AddOnsView`.
//

import SwiftUI
import CoreLocation // if you plan to detect region specifically

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppSettingsView: View {
    // Appearance
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    
    // Timezone: We'll store the user’s chosen default
    @AppStorage("defaultTimezone") private var defaultTimezone: String = ""
    
    @State private var showChangelog = false
    
    // A simple location manager (if you want to guess region from user location)
    @StateObject private var locationManager = LocationRegionDetector()
    
    public var body: some View {
        NavigationView {
            Form {
                
                // MARK: - Add On
                Section("Add On") {
                    NavigationLink("Manage Add-Ons") {
                        AddOnsView()
                    }
                }
                
                // MARK: - Features
                featuresSection
                
                // MARK: - Appearance
                appearanceSection
                
                // MARK: - Timezone
                timezoneSection
                
                // MARK: - Version
                versionSection
                
                // MARK: - Footer
                footerSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showChangelog) {
                ChangelogView()
            }
            .onChange(of: appColorScheme) { newValue in
                applyColorScheme(newValue)
            }
            .onAppear {
                // If no stored timezone, detect system or location-based
                if defaultTimezone.isEmpty {
                    detectInitialTimeZone()
                }
                applyColorScheme(appColorScheme)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Features
    private var featuresSection: some View {
        Section("Features") {
            Toggle("Enable Auto-Updates", isOn: .constant(true))
            Button("Force Version Check") {
                AppVersion.validateAndForceUpdate()
            }
        }
    }
    
    // MARK: - Appearance
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Color Scheme", selection: $appColorScheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Timezone
    private var timezoneSection: some View {
        Section("Timezone") {
            NavigationLink("Change Default Timezone") {
                TimeZonePickerView(currentSelection: $defaultTimezone)
            }
            Text("Current Timezone: \(defaultTimezone)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if locationManager.authorizationStatus == .notDetermined ||
               locationManager.authorizationStatus == .denied {
                Button("Enable Location Services") {
                    locationManager.requestLocationPermission()
                }
            }
        }
    }
    
    // MARK: - Version
    private var versionSection: some View {
        Section("App Version") {
            Text(AppVersion.displayVersionString)
            Button("View Changelog") {
                showChangelog = true
            }
        }
    }
    
    // MARK: - Footer
    private var footerSection: some View {
        Section {
            SettingsFooterView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .textCase(nil)
    }
    
    // MARK: - Color Scheme
    private func applyColorScheme(_ scheme: String) {
        #if !os(macOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        switch scheme {
        case "light":
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
        case "dark":
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .dark }
        default:
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .unspecified }
        }
        #endif
    }
    
    // MARK: - Detect or Default Timezone
    private func detectInitialTimeZone() {
        // 1) If location permission is authorized & we have a region guess, use it.
        if let regionTZ = locationManager.detectedTimeZone {
            defaultTimezone = regionTZ
        } else {
            // 2) Fallback to system's local time zone
            let systemTZ = TimeZone.current
            defaultTimezone = systemTZ.identifier
        }
        print("Initialized default timezone to \(defaultTimezone)")
    }
}
