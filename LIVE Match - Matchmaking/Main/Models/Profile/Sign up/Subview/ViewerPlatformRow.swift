//
//  ViewerPlatformRow.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Single row for each viewer platform.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ViewerPlatformRow: View {
    public let platform: String
    @Binding public var toggledLivePlatforms: Set<String>
    @Binding public var livePlatformUsernames: [String: String]
    @Binding public var livePlatformLinks: [String: String]
    @Binding public var favoriteCreators: [String: [String]]
    
    @State private var newCreator = ""
    
    public init(platform: String,
                toggledLivePlatforms: Binding<Set<String>>,
                livePlatformUsernames: Binding<[String: String]>,
                livePlatformLinks: Binding<[String: String]>,
                favoriteCreators: Binding<[String: [String]]>) {
        self.platform = platform
        self._toggledLivePlatforms = toggledLivePlatforms
        self._livePlatformUsernames = livePlatformUsernames
        self._livePlatformLinks = livePlatformLinks
        self._favoriteCreators = favoriteCreators
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
                
                Text("Favorite Creators on \(platform) (all lowercase)")
                    .font(.subheadline)
                
                if let favs = favoriteCreators[platform], !favs.isEmpty {
                    ForEach(favs, id: \.self) { creator in
                        Text(creator)
                    }
                }
                HStack {
                    TextField("Add favorite creator", text: $newCreator)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        let trimmed = newCreator.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        var list = favoriteCreators[platform] ?? []
                        list.append(trimmed)
                        favoriteCreators[platform] = list
                        newCreator = ""
                    }
                }
            }
        }
    }
}
