//
//  CreatorPlatformList.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Lists multiple creator platforms.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorPlatformList: View {
    public let platformOptions: [String]
    @Binding public var toggledLivePlatforms: Set<String>
    @Binding public var livePlatformUsernames: [String: String]
    @Binding public var livePlatformLinks: [String: String]
    @Binding public var agencyOrNetworkPlatforms: Set<String>
    @Binding public var agencyOrNetworkNames: [String: String]
    @Binding public var selectedAgencyName: String
    @Binding public var showingAgencySearch: Bool
    
    public init(platformOptions: [String],
                toggledLivePlatforms: Binding<Set<String>>,
                livePlatformUsernames: Binding<[String: String]>,
                livePlatformLinks: Binding<[String: String]>,
                agencyOrNetworkPlatforms: Binding<Set<String>>,
                agencyOrNetworkNames: Binding<[String: String]>,
                selectedAgencyName: Binding<String>,
                showingAgencySearch: Binding<Bool>) {
        self.platformOptions = platformOptions
        self._toggledLivePlatforms = toggledLivePlatforms
        self._livePlatformUsernames = livePlatformUsernames
        self._livePlatformLinks = livePlatformLinks
        self._agencyOrNetworkPlatforms = agencyOrNetworkPlatforms
        self._agencyOrNetworkNames = agencyOrNetworkNames
        self._selectedAgencyName = selectedAgencyName
        self._showingAgencySearch = showingAgencySearch
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Creator: LIVE Platform Accounts").font(.headline)
            ForEach(platformOptions, id: \.self) { platform in
                CreatorPlatformRow(
                    platform: platform,
                    toggledLivePlatforms: $toggledLivePlatforms,
                    livePlatformUsernames: $livePlatformUsernames,
                    livePlatformLinks: $livePlatformLinks,
                    agencyOrNetworkPlatforms: $agencyOrNetworkPlatforms,
                    agencyOrNetworkNames: $agencyOrNetworkNames,
                    selectedAgencyName: $selectedAgencyName,
                    showingAgencySearch: $showingAgencySearch
                )
            }
        }
        .padding(.vertical, 8)
    }
}
