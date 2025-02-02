//
//  OwnershipView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
// MARK: - OwnershipView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays the ownership info: Owned by Infinitum Imagery LLC, created by @JrFTW.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct OwnershipView: View {
    // MARK: - Init
    public init() {
        print("[OwnershipView] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[OwnershipView] body invoked. Building UI.")
        
        VStack(spacing: 16) {
            let _ = print("[OwnershipView] Adding text: 'Ownership Info'")
            Text("Ownership Info")
                .font(.title2)
            
            let _ = print("[OwnershipView] Adding text: 'Owned by Infinitum Imagery LLC'")
            Text("Owned by Infinitum Imagery LLC")
                .font(.headline)
            
            let _ = print("[OwnershipView] Adding text: 'Created by @JrFTW'")
            Text("Created by @JrFTW")
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Ownership")
        .navigationBarTitleDisplayMode(.inline)
    }
}
