// MARK: AppSettingsView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// MARK: SECTION: A Priority
// -------------------------------------
// A cross-platform settings screen that displays features, appearance options,
// and a version/changelog section, with a footer. Split into smaller computed
// properties to avoid SwiftUI's complex expression errors.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AppSettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @State private var showChangelog = false
    
    public var body: some View {
        NavigationView {
            Form {
                featuresSection
                appearanceSection
                versionSection
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
                applyColorScheme(appColorScheme)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var featuresSection: some View {
        Section("Features") {
            Toggle("Enable Auto-Updates", isOn: .constant(true))
            Button("Force Version Check") {
                AppVersion.validateAndForceUpdate()
            }
        }
    }
    
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
    
    private var versionSection: some View {
        Section("App Version") {
            Text(AppVersion.displayVersionString)
            Button("View Changelog") {
                showChangelog = true
            }
        }
    }
    
    private var footerSection: some View {
        Section {
            SettingsFooterView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .textCase(nil)
    }
    
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
}
