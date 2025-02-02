//
//  SettingsFooterView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays a custom footer with credits, version, and individually clickable policy links.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SettingsFooterView: View {
    // MARK: - Init
    public init() {
        print("[SettingsFooterView] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[SettingsFooterView] body invoked. Building footer UI.")
        
        VStack(spacing: 10) {
            let _ = print("[SettingsFooterView] Adding text => 'Made in Pittsburgh, PA USA 🇺🇸'")
            Text("Made in Pittsburgh, PA USA 🇺🇸")
            
            let _ = print("[SettingsFooterView] Adding text => 'LIVE Match - Matchmaker Current Version: \(AppVersion.displayVersionString)'")
            Text("LIVE Match - Matchmaker Current Version: \(AppVersion.displayVersionString)")
            
            let _ = print("[SettingsFooterView] Adding text => '© 2025 Infinitum Imagery LLC & Infinitum_US'")
            Text("© 2025 Infinitum Imagery LLC & Infinitum_US")
            
            let _ = print("[SettingsFooterView] Adding text => 'Made by @JrFTW All Rights Reserved'")
            Text("Made by @JrFTW All Rights Reserved")
                .padding(.bottom, 8)
            
            let _ = print("[SettingsFooterView] Adding NavigationLink => 'Terms & Conditions'")
            NavigationLink(
                destination: WebLinkView(
                    title: "Terms & Conditions",
                    urlString: "https://infinitumlive.com/live-match-matchmaking-app/"
                )
            ) {
                Text("Terms & Conditions")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
            
            let _ = print("[SettingsFooterView] Adding NavigationLink => 'Privacy Policy'")
            NavigationLink(
                destination: WebLinkView(
                    title: "Privacy Policy",
                    urlString: "https://infinitumlive.com/live-match-match-making-privacy-policy/"
                )
            ) {
                Text("Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
            
            let _ = print("[SettingsFooterView] Adding NavigationLink => 'Ownership'")
            NavigationLink(destination: OwnershipView()) {
                Text("Ownership")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 8)
    }
}
