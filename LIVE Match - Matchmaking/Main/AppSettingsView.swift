//
//  AppSettingsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: AppSettingsView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Cross-platform settings screen that displays features, appearance,
// and app version/changelog in a reordered layout, with a footer at the bottom.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct AppSettingsView: View {
    @AppStorage("appColorScheme") private var appColorScheme: String = "system"
    @State private var showChangelog = false
    
    var body: some View {
        Form {
            // MARK: Features Section (top)
            Section("Features") {
                Toggle("Enable Auto-Updates", isOn: .constant(true))
                Button("Force Version Check") {
                    AppVersion.validateAndForceUpdate()
                }
            }
            
            // MARK: Appearance Section (middle)
            Section("Appearance") {
                Picker("Color Scheme", selection: $appColorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }
            
            // MARK: App Version Section (bottom)
            Section("App Version") {
                Text(AppVersion.displayVersionString)
                Button("View Changelog") {
                    showChangelog = true
                }
            }
            
            // MARK: Footer Section
            Section {
                SettingsFooterView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .textCase(nil)
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
    
    private func applyColorScheme(_ scheme: String) {
        #if !os(macOS)
        guard let scene = UIApplication.shared
            .connectedScenes
            .first as? UIWindowScene else { return }
        
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

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct ChangelogView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(Changelog.entries) { entry in
                    Section(header: Text("Version \(entry.version) (Build \(entry.build)) — Released \(entry.releaseDate)")) {
                        ForEach(entry.changes, id: \.self) { line in
                            Text("• \(line)")
                        }
                    }
                }
            }
            .navigationTitle("Changelog")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
