// MARK: ReorderManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Manages reorderable menu items, including optional hide/unhide.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ReorderManager: ObservableObject {
    
    // Each item can be hidden or shown. 'sortOrder' determines its position.
    public struct ReorderableMenuItem: Identifiable {
        public let id: UUID
        public var title: String
        public var icon: String
        public var color: Color
        public var destination: AnyView
        public var sortOrder: Int
        
        // Toggle for user to hide or unhide
        public var isHidden: Bool
        
        public init(
            id: UUID,
            title: String,
            icon: String,
            color: Color,
            destination: AnyView,
            sortOrder: Int,
            isHidden: Bool = false
        ) {
            self.id = id
            self.title = title
            self.icon = icon
            self.color = color
            self.destination = destination
            self.sortOrder = sortOrder
            self.isHidden = isHidden
        }
    }
    
    @Published public private(set) var activeItems: [ReorderableMenuItem] = []
    
    // 'Settings' is pinned at the bottom
    private let settingsKey = "Settings"
    
    public init() {}
    
    // Convert from MainMenuView.MenuItem to ReorderableMenuItem
    public func loadItems(with items: [MainMenuView.MenuItem]) {
        var reorderables: [ReorderableMenuItem] = []
        for (index, raw) in items.enumerated() {
            let forcedOrder = (raw.title == settingsKey) ? 9999 : index
            let reorderable = ReorderableMenuItem(
                id: raw.id,
                title: raw.title,
                icon: raw.icon,
                color: raw.color,
                destination: raw.destination,
                sortOrder: forcedOrder,
                isHidden: false
            )
            reorderables.append(reorderable)
        }
        // Sort by sortOrder
        self.activeItems = reorderables.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // Move item up
    public func moveItemUp(_ title: String) {
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else { return }
        guard idx > 0 else { return }
        if activeItems[idx].title == settingsKey { return }
        if activeItems[idx - 1].title == settingsKey { return }
        
        activeItems.swapAt(idx, idx - 1)
        updateSortOrders()
    }
    
    // Move item down
    public func moveItemDown(_ title: String) {
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else { return }
        guard idx < activeItems.count - 1 else { return }
        if activeItems[idx].title == settingsKey { return }
        if activeItems[idx + 1].title == settingsKey { return }
        
        activeItems.swapAt(idx, idx + 1)
        updateSortOrders()
    }
    
    // Toggle hidden
    public func toggleHidden(_ title: String) {
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else { return }
        // If it's 'Settings', skip
        if activeItems[idx].title == settingsKey { return }
        
        activeItems[idx].isHidden.toggle()
    }
    
    // Recompute order after a move
    private func updateSortOrders() {
        for i in activeItems.indices {
            if activeItems[i].title == settingsKey {
                activeItems[i].sortOrder = 9999
            } else {
                activeItems[i].sortOrder = i
            }
        }
        activeItems.sort { $0.sortOrder < $1.sortOrder }
    }
}
