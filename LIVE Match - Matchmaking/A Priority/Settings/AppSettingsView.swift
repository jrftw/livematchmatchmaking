// MARK: - AppSettingsView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------

import SwiftUI
import CoreLocation
import FirebaseAuth

#if canImport(UIKit)
import SafariServices
import WebKit
#endif

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppSettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @AppStorage("defaultTimezone") private var defaultTimezone: String = ""
    
    @State private var showChangelog = false
    @State private var showInAppBrowser = false
    
    // MARK: - Preloaded WebViews
    #if canImport(UIKit)
    @State private var bugReportWebView = WKWebView()
    @State private var featureRequestWebView = WKWebView()
    @State private var discordFallbackWebView = WKWebView()
    @State private var currentWebView: WKWebView? = nil
    #endif
    
    @StateObject private var locationManager = LocationRegionDetector()
    @StateObject private var notificationManager = NotificationManager()
    
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
                notificationsSection()
                appearanceSection()
                timezoneSection()
                versionSection()
                supportSection()
                ForceLogoutSection(selectedScreen: $selectedScreen)
                footerSection()
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showChangelog) {
                ChangelogView()
            }
            #if canImport(UIKit)
            .sheet(isPresented: $showInAppBrowser) {
                if let wv = currentWebView {
                    InAppBrowserView(webView: wv)
                }
            }
            #endif
            .onChange(of: appColorScheme) { newValue in
                applyColorScheme(newValue)
            }
            .onAppear {
                if defaultTimezone.isEmpty {
                    detectInitialTimeZone()
                }
                applyColorScheme(appColorScheme)
                
                // Preload links
                #if canImport(UIKit)
                bugReportWebView.load(URLRequest(url: URL(string: "https://forms.gle/w7CFZUtyEXS8yqeg8")!))
                featureRequestWebView.load(URLRequest(url: URL(string: "https://forms.gle/ekGuuymLZPBee13E9")!))
                discordFallbackWebView.load(URLRequest(url: URL(string: "https://discord.gg/gJK9PH4eDR")!))
                #endif
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Sections
    // -------------------------------------------------------
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
    
    private func notificationsSection() -> some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $notificationManager.isNotificationsEnabled)
            Button("Request Permission") {
                notificationManager.requestNotificationPermission()
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
            #if canImport(UIKit)
            Button("Bug Report") {
                currentWebView = bugReportWebView
                showInAppBrowser = true
            }
            Button("Feature Request") {
                currentWebView = featureRequestWebView
                showInAppBrowser = true
            }
            #else
            Button("Bug Report") { }
            Button("Feature Request") { }
            #endif
        }
    }
    
    private func footerSection() -> some View {
        Section {
            SettingsFooterView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .textCase(nil)
    }
    
    // MARK: - Helpers
    // -------------------------------------------------------
    private func applyColorScheme(_ scheme: String) {
        #if os(iOS)
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
        #if os(iOS)
        if let url = URL(string: "mailto:jrftw@infinitumlive.com") {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    private func openDiscord() {
        #if os(iOS)
        let discordDeeplink = URL(string: "discord://invite/gJK9PH4eDR")!
        if UIApplication.shared.canOpenURL(discordDeeplink) {
            UIApplication.shared.open(discordDeeplink)
        } else {
            // Fallback to in-app web view
            currentWebView = discordFallbackWebView
            showInAppBrowser = true
        }
        #endif
    }
}

// MARK: - InAppBrowserView
// -------------------------------------------------------
#if canImport(UIKit)
@available(iOS 15.0, *)
struct InAppBrowserView: View {
    let webView: WKWebView
    
    var body: some View {
        NavigationView {
            SwiftUIWKWebView(webView: webView)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismissSheet()
                        }
                    }
                }
        }
    }
    
    @Environment(\.presentationMode) private var presentationMode
    
    private func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - SwiftUIWKWebView
@available(iOS 15.0, *)
struct SwiftUIWKWebView: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates required
    }
}
#endif
