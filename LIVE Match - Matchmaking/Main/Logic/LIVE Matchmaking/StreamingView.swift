//
//  StreamingView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  LIVE Streaming “matchmaking” screen with “Creator vs Creator,” bracket setups, plus “My Brackets.”
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct StreamingView: View {
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
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Platforms")) {
                    ForEach(platforms) { platform in
                        NavigationLink(destination: StreamingPlatformDetailView(platform: platform)) {
                            Text(platform.name)
                        }
                    }
                }
                
                Section(header: Text("My Brackets")) {
                    NavigationLink("Manage My Brackets", destination: MyBracketsListView())
                }
            }
            .navigationTitle("LIVE Streaming")
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct StreamingPlatformDetailView: View {
    public let platform: LivePlatformOption
    
    public init(platform: LivePlatformOption) {
        self.platform = platform
    }
    
    public var body: some View {
        List {
            Section(header: Text("Match Options")) {
                NavigationLink("Creator vs Creator", destination: CreatorVsCreatorView(platform: platform))
            }
            Section(header: Text("Bracket Options")) {
                NavigationLink("CN Internal Bracket",
                               destination: AdvancedBracketCreationView(title: "CN Internal Bracket", platform: platform))
                NavigationLink("Agency Internal Bracket",
                               destination: AdvancedBracketCreationView(title: "Agency Internal Bracket", platform: platform))
                NavigationLink("Open Bracket",
                               destination: AdvancedBracketCreationView(title: "Open Bracket", platform: platform))
            }
        }
        .navigationTitle(platform.name)
    }
}
