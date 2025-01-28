// MARK: File 1: LiveMatchmakingView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Main entry list of platforms for LIVE matchmaking.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct LiveMatchmakingView: View {
    @State private var selectedPlatform: LivePlatformOption? = nil
    
    private let platforms: [LivePlatformOption] = [
        .init(name: "TikTok"),
        .init(name: "Favorited"),
        .init(name: "Mango"),
        .init(name: "LIVE.Me"),
        .init(name: "YouNow"),
        .init(name: "YouTube"),
        .init(name: "Clapper"),
        .init(name: "Fanbase"),
        .init(name: "kick")
    ]
    
    var body: some View {
        NavigationView {
            List(platforms) { platform in
                NavigationLink(destination: PlatformDetailView(platform: platform)) {
                    Text(platform.name)
                }
            }
            .navigationTitle("LIVE Matchmaking")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
