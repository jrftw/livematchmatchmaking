//
//  SettingsFooterView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  Footer.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: Footer.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A view that displays a custom footer with credits, version, and placeholders for policy links.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct SettingsFooterView: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("Made in Pittsburgh, PA USA 🇺🇸")
            Text("LIVE Match - Matchmaker Current Version: \(AppVersion.displayVersionString)")
            Text("© 2025 Infinitum Imagery LLC & Infinitum LIVE Creator Network")
            Text("Made by @JrFTW All Rights Reserved")
            
            // In production, these might be NavigationLinks or WebView links.
            Text("Privacy Policy (placeholder)")
                .foregroundColor(.blue)
            Text("Terms of Service (placeholder)")
                .foregroundColor(.blue)
            Text("Ownership (placeholder)")
                .foregroundColor(.blue)
        }
        .font(.footnote)
        .multilineTextAlignment(.center)
        .padding(.vertical, 8)
    }
}