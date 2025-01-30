//
//  CreatorPlatformRow.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


//
//  CreatorPlatformRow.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Single row for each creator platform.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorPlatformRow: View {
    public let platform: String
    @Binding public var toggledLivePlatforms: Set<String>
    @Binding public var livePlatformUsernames: [String: String]
    @Binding public var livePlatformLinks: [String: String]
    @Binding public var agencyOrNetworkPlatforms: Set<String>
    @Binding public var agencyOrNetworkNames: [String: String]
    @Binding public var selectedAgencyName: String
    @Binding public var showingAgencySearch: Bool
    
    public init(platform: String,
                toggledLivePlatforms: Binding<Set<String>>,
                livePlatformUsernames: Binding<[String: String]>,
                livePlatformLinks: Binding<[String: String]>,
                agencyOrNetworkPlatforms: Binding<Set<String>>,
                agencyOrNetworkNames: Binding<[String: String]>,
                selectedAgencyName: Binding<String>,
                showingAgencySearch: Binding<Bool>) {
        self.platform = platform
        self._toggledLivePlatforms = toggledLivePlatforms
        self._livePlatformUsernames = livePlatformUsernames
        self._livePlatformLinks = livePlatformLinks
        self._agencyOrNetworkPlatforms = agencyOrNetworkPlatforms
        self._agencyOrNetworkNames = agencyOrNetworkNames
        self._selectedAgencyName = selectedAgencyName
        self._showingAgencySearch = showingAgencySearch
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: Binding<Bool>(
                get: { toggledLivePlatforms.contains(platform) },
                set: { newVal in
                    if newVal {
                        toggledLivePlatforms.insert(platform)
                    } else {
                        toggledLivePlatforms.remove(platform)
                        livePlatformUsernames[platform] = nil
                        livePlatformLinks[platform] = nil
                        agencyOrNetworkNames[platform] = nil
                        agencyOrNetworkPlatforms.remove(platform)
                    }
                }
            )) {
                Text(platform)
            }
            
            if toggledLivePlatforms.contains(platform) {
                TextField("\(platform) username (all lowercase)",
                          text: Binding<String>(
                            get: { livePlatformUsernames[platform] ?? "" },
                            set: { livePlatformUsernames[platform] = $0.lowercased() }
                          )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("\(platform) profile link",
                          text: Binding<String>(
                            get: { livePlatformLinks[platform] ?? "" },
                            set: { livePlatformLinks[platform] = $0 }
                          )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Toggle("On an Agency or Creator Network?",
                       isOn: Binding<Bool>(
                        get: { agencyOrNetworkPlatforms.contains(platform) },
                        set: { val in
                            if val {
                                agencyOrNetworkPlatforms.insert(platform)
                            } else {
                                agencyOrNetworkPlatforms.remove(platform)
                                agencyOrNetworkNames[platform] = nil
                            }
                        }
                ))
                .padding(.top, 4)
                
                if agencyOrNetworkPlatforms.contains(platform) {
                    Button("Select Agency / Network") {
                        selectedAgencyName = platform
                        showingAgencySearch = true
                    }
                    
                    if let entered = agencyOrNetworkNames[platform], !entered.isEmpty {
                        Text("Current selection: \(entered)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}