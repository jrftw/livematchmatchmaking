//
//  EULAWrapperView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/5/25.
//


// MARK: - EULAWrapperView.swift
// Wraps the EULAView and PostRowView. Shows EULA first if not accepted.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct EULAWrapperView: View {
    @AppStorage("didAcceptEULA") private var didAcceptEULA = false
    public let post: Post
    
    public init(post: Post) {
        self.post = post
    }
    
    public var body: some View {
        if didAcceptEULA {
            PostRowView(post: post)
        } else {
            EULAView()
        }
    }
}