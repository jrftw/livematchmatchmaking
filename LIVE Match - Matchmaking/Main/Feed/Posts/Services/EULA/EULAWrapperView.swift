//
//  EULAWrapperView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/5/25.
//

// MARK: - EULAWrapperView.swift
// Wraps the EULAView and PostRowView. Shows the EULA in a sheet if not accepted.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct EULAWrapperView: View {
    @AppStorage("didAcceptEULA") private var didAcceptEULA = false
    
    public let post: Post
    @State private var showEULA = false
    
    public init(post: Post) {
        self.post = post
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            PostRowView(post: post)
        }
        .onAppear {
            if !didAcceptEULA {
                showEULA = true
            }
        }
        .sheet(isPresented: $showEULA) {
            EULAView()
        }
    }
}
