//
//  ReorderManager.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//

// MARK: ReorderManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A separate file handling the reordering logic.
// "Settings" is always placed last, ignoring reorder attempts.
// Removed conformance to 'Equatable' to avoid AnyView comparison error.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ReorderManager: ObservableObject {
    
    // MARK: ReorderableMenuItem
    // Removed 'Equatable' to avoid the AnyView comparison error.
    // The rest of the logic remains the same.
    public struct ReorderableMenuItem: Identifiable {
        public let id: UUID
        public var title: String
        public var icon: String
        public var color: Color
        public var destination: AnyView
        public var sortOrder: Int
        
        public init(
            id: UUID,
            title: String,
            icon: String,
            color: Color,
            destination: AnyView,
            sortOrder: Int
        ) {
            self.id = id
            self.title = title
            self.icon = icon
            self.color = color
            self.destination = destination
            self.sortOrder = sortOrder
        }
    }
    
    // MARK: Properties
    @Published public private(set) var activeItems: [ReorderableMenuItem] = []
    
    private let settingsKey = "Settings"
    
    // MARK: Initializer
    public init() {}
    
    // MARK: Load Items
    // Make this internal (default) to avoid mismatch with MainMenuView.MenuItem (which is internal).
    func loadItems(with items: [MainMenuView.MenuItem]) {
        var reorderables: [ReorderableMenuItem] = []
        for (index, raw) in items.enumerated() {
            // If it's "Settings", assign a large sortOrder
            let forcedOrder = (raw.title == settingsKey) ? 9999 : index
            let reorderable = ReorderableMenuItem(
                id: raw.id,
                title: raw.title,
                icon: raw.icon,
                color: raw.color,
                destination: raw.destination,
                sortOrder: forcedOrder
            )
            reorderables.append(reorderable)
        }
        self.activeItems = reorderables.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: Move Item Up
    // Make these internal to match the internal loadItems(...) visibility.
    func moveItemUp(_ title: String) {
        guard let index = activeItems.firstIndex(where: { $0.title == title }) else { return }
        if activeItems[index].title == settingsKey { return }
        guard index > 0 else { return }
        
        // If the above item is "Settings", skip
        if activeItems[index - 1].title == settingsKey { return }
        
        activeItems.swapAt(index, index - 1)
        updateSortOrders()
    }
    
    // MARK: Move Item Down
    func moveItemDown(_ title: String) {
        guard let index = activeItems.firstIndex(where: { $0.title == title }) else { return }
        if activeItems[index].title == settingsKey { return }
        guard index < activeItems.count - 1 else { return }
        
        // If the below item is "Settings", skip
        if activeItems[index + 1].title == settingsKey { return }
        
        activeItems.swapAt(index, index + 1)
        updateSortOrders()
    }
    
    // MARK: Update Sort Orders
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
