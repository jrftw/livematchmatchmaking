// MARK: DraggableHandleOverlay.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Overlay with buttons to move items up, move items down, and optionally hide them.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DraggableHandleOverlay: View {
    // MARK: - Properties
    let isEditing: Bool
    let title: String
    @ObservedObject var reorderManager: ReorderManager
    
    // MARK: - Body
    var body: some View {
        let _ = print("[DraggableHandleOverlay] body invoked. isEditing: \(isEditing), title: \(title)")
        
        if isEditing {
            let _ = print("[DraggableHandleOverlay] isEditing == true. Building overlay with move up/down/hide buttons for title: \(title)")
            
            VStack(spacing: 8) {
                
                // Move Up
                Button {
                    print("[DraggableHandleOverlay] 'Move Up' button tapped for item: \(title)")
                    reorderManager.moveItemUp(title)
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                // Move Down
                Button {
                    print("[DraggableHandleOverlay] 'Move Down' button tapped for item: \(title)")
                    reorderManager.moveItemDown(title)
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                // Hide/Unhide
                Button {
                    print("[DraggableHandleOverlay] 'Hide/Unhide' button tapped for item: \(title)")
                    reorderManager.toggleHidden(title)
                } label: {
                    Image(systemName: "eye.slash")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
            }
        } else {
            let _ = print("[DraggableHandleOverlay] isEditing == false. No overlay displayed for title: \(title).")
        }
    }
}
