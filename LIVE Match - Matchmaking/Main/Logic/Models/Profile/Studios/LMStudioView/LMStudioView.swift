// MARK: LMStudioView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Main container for LM Studio: Viewer, Creator, Gamer, Community sections.

import SwiftUI
import Firebase
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LMStudioView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                NavigationLink("Viewer Section") {
                    ViewerStudioView()
                }
                NavigationLink("Creator Section") {
                    CreatorStudioView()
                }
                NavigationLink("Gamer Section") {
                    GamerStudioView()
                }
                NavigationLink("Community Section") {
                    CommunityStudioView()
                }
            }
            .navigationTitle("LM Studio")
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
