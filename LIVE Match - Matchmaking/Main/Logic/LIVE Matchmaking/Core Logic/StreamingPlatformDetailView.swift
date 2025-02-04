// FILE: StreamingPlatformDetailView.swift
// UPDATED FILE

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct StreamingPlatformDetailView: View {
    public let platform: LivePlatformOption
    
    public init(platform: LivePlatformOption) {
        self.platform = platform
    }
    
    public var body: some View {
        List {
            Section(header: Text("Find Match")) {
                NavigationLink("Creator vs Creator") {
                    CreatorVsCreatorView(platform: platform)
                }
                // Same change: "Find slots to fill" => FillInBracketFinderView
                NavigationLink("Find slots to fill") {
                    FillInBracketFinderView()
                }
            }
            Section(header: Text("Build Brackets")) {
                NavigationLink("CN Internal Bracket") {
                    AdvancedBracketCreationView(
                        title: "CN Internal Bracket",
                        platform: platform
                    )
                }
                NavigationLink("Agency Internal Bracket") {
                    AdvancedBracketCreationView(
                        title: "Agency Internal Bracket",
                        platform: platform
                    )
                }
                NavigationLink("Open Brackets") {
                    AdvancedBracketCreationView(
                        title: "Open Brackets",
                        platform: platform
                    )
                }
                // Keep building new brackets
                NavigationLink("Fill In Brackets") {
                    FillInBracketCreationView(
                        title: "Fill-In Bracket",
                        platform: platform
                    )
                }
            }
        }
        .navigationTitle(platform.name)
    }
}
