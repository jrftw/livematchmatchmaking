// MARK: - AppSettingsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI
import CoreLocation
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppSettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @AppStorage("defaultTimezone") private var defaultTimezone: String = ""
    
    @State private var showChangelog = false
    @StateObject private var locationManager = LocationRegionDetector()
    
    // Must accept selectedScreen so we can pass it to ForceLogoutSection
    @Binding var selectedScreen: MainScreen
    
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
        print("[AppSettingsView] init called. appColorScheme: \(appColorScheme), defaultTimezone: \(defaultTimezone)")
    }
    
    public var body: some View {
        print("[AppSettingsView] body invoked.")
        
        return NavigationView {
            Form {
                addOnSection()
                featuresSection()
                appearanceSection()
                timezoneSection()
                versionSection()
                supportSection()
                
                // ForceLogoutSection now requires the binding
                ForceLogoutSection(selectedScreen: $selectedScreen)
                
                footerSection()
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showChangelog) {
                ChangelogView()
            }
            .onChange(of: appColorScheme) { newValue in
                applyColorScheme(newValue)
            }
            .onAppear {
                if defaultTimezone.isEmpty {
                    detectInitialTimeZone()
                }
                applyColorScheme(appColorScheme)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func addOnSection() -> some View {
        Section("Add On") {
            NavigationLink("Manage Add-Ons") {
                AddOnsView()
            }
        }
    }
    
    private func featuresSection() -> some View {
        Section("Features") {
            Toggle("Enable Auto-Updates", isOn: .constant(true))
            Button("Force Version Check") {
                AppVersion.validateAndForceUpdate()
            }
        }
    }
    
    private func appearanceSection() -> some View {
        Section("Appearance") {
            Picker("Color Scheme", selection: $appColorScheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func timezoneSection() -> some View {
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
    
    private func versionSection() -> some View {
        Section("App Version") {
            Text(AppVersion.displayVersionString)
            Button("View Changelog") {
                showChangelog = true
            }
        }
    }
    
    private func supportSection() -> some View {
        Section("Support") {
            Button("Contact") {
                openMail()
            }
            Button("Join the Discord") {
                openDiscord()
            }
        }
    }
    
    private func footerSection() -> some View {
        Section {
            SettingsFooterView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .textCase(nil)
    }
    
    private func applyColorScheme(_ scheme: String) {
        #if !os(macOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
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
    
    private func detectInitialTimeZone() {
        if let regionTZ = locationManager.detectedTimeZone {
            defaultTimezone = regionTZ
        } else {
            let systemTZ = TimeZone.current
            defaultTimezone = systemTZ.identifier
        }
    }
    
    private func openMail() {
        #if !os(macOS)
        if let url = URL(string: "mailto:jrftw@infinitumlive.com") {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    private func openDiscord() {
        #if !os(macOS)
        if let url = URL(string: "https://discord.gg/gJK9PH4eDR") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}
