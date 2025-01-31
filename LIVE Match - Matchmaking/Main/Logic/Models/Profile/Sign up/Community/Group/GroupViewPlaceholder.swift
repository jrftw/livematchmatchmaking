// MARK: GroupViewPlaceholder.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct GroupViewPlaceholder: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Group View Placeholder")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationTitle("Group")
    }
}
