//
//  OwnershipView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//


//
//  OwnershipView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays the ownership info: Owned by Infinitum Imagery LLC, created by @JrFTW.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct OwnershipView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Ownership Info")
                .font(.title2)
            
            Text("Owned by Infinitum Imagery LLC")
                .font(.headline)
            
            Text("Created by @JrFTW")
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Ownership")
        .navigationBarTitleDisplayMode(.inline)
    }
}