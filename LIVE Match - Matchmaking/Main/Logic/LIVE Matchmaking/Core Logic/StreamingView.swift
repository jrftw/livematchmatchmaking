// MARK: StreamingView.swift

//
//  StreamingView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Main “LIVE” matchmaking entry.
//

import SwiftUI

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
        .init(name: "Kick")
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Platforms")) {
                    ForEach(platforms) { platform in
                        NavigationLink(platform.name) {
                            StreamingPlatformDetailView(platform: platform)
                        }
                    }
                }
                Section(header: Text("My Brackets")) {
                    NavigationLink("Manage My Brackets") {
                        MyBracketsListView()
                    }
                }
            }
            .navigationTitle("LIVE Streaming")
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
