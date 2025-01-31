//
//  ViewerPlatformList.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//  Lists multiple viewer platforms.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ViewerPlatformList: View {
    public let platformOptions: [String]
    @Binding public var toggledLivePlatforms: Set<String>
    @Binding public var livePlatformUsernames: [String: String]
    @Binding public var livePlatformLinks: [String: String]
    @Binding public var favoriteCreators: [String: [String]]
    
    public init(platformOptions: [String],
                toggledLivePlatforms: Binding<Set<String>>,
                livePlatformUsernames: Binding<[String: String]>,
                livePlatformLinks: Binding<[String: String]>,
                favoriteCreators: Binding<[String: [String]]>) {
        self.platformOptions = platformOptions
        self._toggledLivePlatforms = toggledLivePlatforms
        self._livePlatformUsernames = livePlatformUsernames
        self._livePlatformLinks = livePlatformLinks
        self._favoriteCreators = favoriteCreators
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Viewer: LIVE Platform Accounts").font(.headline)
            ForEach(platformOptions, id: \.self) { platform in
                ViewerPlatformRow(
                    platform: platform,
                    toggledLivePlatforms: $toggledLivePlatforms,
                    livePlatformUsernames: $livePlatformUsernames,
                    livePlatformLinks: $livePlatformLinks,
                    favoriteCreators: $favoriteCreators
                )
            }
        }
        .padding(.vertical, 8)
    }
}
