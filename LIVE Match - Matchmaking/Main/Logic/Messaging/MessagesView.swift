//
//  MessagesView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/29/25.
//


// MARK: MessagesView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Simple wrapper that displays or references DirectMessagesListView in one place.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct MessagesView: View {
    var body: some View {
        DirectMessagesListView()
    }
}