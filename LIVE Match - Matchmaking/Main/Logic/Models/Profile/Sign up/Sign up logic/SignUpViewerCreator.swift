//
//  SignUpViewerCreator.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Viewer and Creator LIVE platform sections as an extension to SignUpMainContent.
//  Includes the sheet presentation so that when you click "Select Agency / Network",
//  the `agencyNetworkSearchView()` is actually displayed.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension SignUpMainContent {
    
    // MARK: - Viewer Section
    func viewerLivePlatformSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Viewer: LIVE Platform Accounts").font(.headline)
            let platformOptions = ["TikTok", "Favorited", "Mango", "LIVE.Me", "YouNow", "YouTube", "Clapper", "Fanbase", "Kick", "Other"]
            ForEach(platformOptions, id: \.self) { platform in
                Toggle(isOn: Binding<Bool>(
                    get: { toggledLivePlatforms.contains(platform) },
                    set: { newVal in
                        if newVal {
                            toggledLivePlatforms.insert(platform)
                        } else {
                            toggledLivePlatforms.remove(platform)
                            livePlatformUsernames[platform] = nil
                            livePlatformLinks[platform] = nil
                            favoriteCreators[platform] = []
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
                    
                    viewerFavoriteCreatorSection(for: platform)
                }
            }
        }
        .padding(.vertical, 8)
        // Ensures the agency/network sheet can be presented if needed
        .sheet(isPresented: $showingAgencySearch) {
            agencyNetworkSearchView()
        }
    }
    
    // MARK: - Viewer Favorite Creators
    func viewerFavoriteCreatorSection(for platform: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Favorite Creators on \(platform) (all lowercase)")
                .font(.subheadline)
            let favs = favoriteCreators[platform] ?? []
            if !favs.isEmpty {
                ForEach(favs, id: \.self) { creator in
                    Text(creator)
                }
            }
            HStack {
                let binding = Binding<String>(
                    get: { "" },
                    set: { newVal in
                        let trim = newVal.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trim.isEmpty else { return }
                        var list = favoriteCreators[platform] ?? []
                        list.append(trim)
                        favoriteCreators[platform] = list
                    }
                )
                TextField("Add favorite creator", text: binding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") { }
            }
        }
        .padding(.leading, 16)
    }
    
    // MARK: - Creator Section
    func creatorLivePlatformSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Creator: LIVE Platform Accounts").font(.headline)
            let platformOptions = ["TikTok", "Favorited", "Mango", "LIVE.Me", "YouNow", "YouTube", "Clapper", "Fanbase", "Kick", "Other"]
            ForEach(platformOptions, id: \.self) { platform in
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
                    
                    Toggle("Are you on an Agency or Creator Network for \(platform)?",
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
        .padding(.vertical, 8)
        // Ensures the agency/network sheet can be presented if needed
        .sheet(isPresented: $showingAgencySearch) {
            agencyNetworkSearchView()
        }
    }
}
