// FILE: PlatformDetailView.swift
// UPDATED FILE

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PlatformDetailView: View {
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
                // Change this to the new FillInBracketFinderView,
                // so users can discover existing brackets/slots.
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
                NavigationLink("Open Bracket") {
                    AdvancedBracketCreationView(
                        title: "Open Bracket",
                        platform: platform
                    )
                }
                // Keep "Build a Fill in Bracket" pointing to creation logic.
                NavigationLink("Fill In Brackets") {
                    FillInBracketCreationView(
                        title: "Fill-In Brackets",
                        platform: platform
                    )
                }
            }
        }
        .navigationTitle(platform.name)
    }
}
