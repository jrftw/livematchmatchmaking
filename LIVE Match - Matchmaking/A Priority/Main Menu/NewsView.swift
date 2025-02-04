//
//  NewsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//


// FILE: NewsView.swift

import SwiftUI

// MARK: - NewsView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct NewsView: View {
    // MARK: Init
    public init() {}
    
    // MARK: Body
    public var body: some View {
        VStack {
            Text("News")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            Text("Stay tuned for the latest updates!")
        }
        .padding()
    }
}
