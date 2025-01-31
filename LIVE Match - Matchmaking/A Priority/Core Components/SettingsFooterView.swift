//
//  SettingsFooterView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//  Displays a custom footer with credits, version, and individually clickable policy links.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct SettingsFooterView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Made in Pittsburgh, PA USA 🇺🇸")
            Text("LIVE Match - Matchmaker Current Version: \(AppVersion.displayVersionString)")
            Text("© 2025 Infinitum Imagery LLC & Infinitum_US")
            Text("Made by @JrFTW All Rights Reserved")
                .padding(.bottom, 8)
            
            // Each link is centered individually, and only that text is clickable.
            NavigationLink(destination: WebLinkView(
                title: "Terms & Conditions",
                urlString: "https://infinitumlive.com/live-match-matchmaking-app/"
            )) {
                Text("Terms & Conditions")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
            
            NavigationLink(destination: WebLinkView(
                title: "Privacy Policy",
                urlString: "https://infinitumlive.com/live-match-match-making-privacy-policy/"
            )) {
                Text("Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .underline()
            }
            
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
