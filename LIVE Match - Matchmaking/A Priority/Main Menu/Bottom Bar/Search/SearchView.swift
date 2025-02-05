//
//  SearchView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/5/25.
//


//
//  SearchView.swift
//  LIVE Match - Matchmaking
//
//  A placeholder view for the Search screen.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SearchView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Search Screen (Coming Soon)")
                .font(.title)
                .padding()
            
            Text("Currently disabled in the BottomBarView.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}