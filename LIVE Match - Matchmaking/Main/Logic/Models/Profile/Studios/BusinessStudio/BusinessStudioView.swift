// MARK: BusinessStudioView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
// Main container for the "Business Studio":
// - Team Section
// - Agency / Creator Network Section

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BusinessStudioView: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                NavigationLink("Team Section") {
                    TeamStudioView() // Existing or planned view
                }
                NavigationLink("Agency / Creator Network Section") {
                    AgencyCreatorNetworkStudioView() // New view
                }
            }
            .navigationTitle("Business Studio")
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
