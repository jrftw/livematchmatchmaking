//
//  DraggableHandleOverlay.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: DraggableHandleOverlay.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A minimal overlay with up/down arrows to reorder items. 
// Real apps might use a more advanced drag approach or .move() in a List.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DraggableHandleOverlay: View {
    let isEditing: Bool
    let title: String
    @ObservedObject var reorderManager: ReorderManager
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                reorderManager.moveItemUp(title)
            } label: {
                Image(systemName: "chevron.up")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            
            Button {
                reorderManager.moveItemDown(title)
            } label: {
                Image(systemName: "chevron.down")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
        }
    }
}