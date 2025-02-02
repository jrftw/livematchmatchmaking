// MARK: ReorderManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Manages reorderable menu items, including optional hide/unhide.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ReorderManager: ObservableObject {
    
    // MARK: - ReorderableMenuItem
    // Each item can be hidden or shown. 'sortOrder' determines its position.
    public struct ReorderableMenuItem: Identifiable {
        public let id: UUID
        public var title: String
        public var icon: String
        public var color: Color
        public var destination: AnyView
        public var sortOrder: Int
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
            print("[ReorderableMenuItem] init => id: \(id), title: \(title), icon: \(icon), sortOrder: \(sortOrder), isHidden: \(isHidden)")
            self.id = id
            self.title = title
            self.icon = icon
            self.color = color
            self.destination = destination
            self.sortOrder = sortOrder
            self.isHidden = isHidden
            print("[ReorderableMenuItem] init completed.")
        }
    }
    
    // MARK: - Properties
    @Published public private(set) var activeItems: [ReorderableMenuItem] = []
    private let settingsKey = "Settings"  // 'Settings' is pinned at the bottom
    
    // MARK: - Init
    public init() {
        print("[ReorderManager] init called. Initial activeItems count: \(activeItems.count)")
    }
    
    // MARK: - Load Items
    // Convert from MainMenuView.MenuItem to ReorderableMenuItem
    public func loadItems(with items: [MainMenuView.MenuItem]) {
        print("[ReorderManager] loadItems called with \(items.count) items.")
        
        var reorderables: [ReorderableMenuItem] = []
        for (index, raw) in items.enumerated() {
            print("[ReorderManager] Processing item => title: \(raw.title), index: \(index)")
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
        
        print("[ReorderManager] Sorting reorderables by sortOrder.")
        self.activeItems = reorderables.sorted { $0.sortOrder < $1.sortOrder }
        print("[ReorderManager] loadItems completed. activeItems count: \(activeItems.count)")
    }
    
    // MARK: - Move Item Up
    public func moveItemUp(_ title: String) {
        print("[ReorderManager] moveItemUp called for title: \(title)")
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else {
            print("[ReorderManager] moveItemUp => Item not found.")
            return
        }
        guard idx > 0 else {
            print("[ReorderManager] moveItemUp => Already at top or invalid index.")
            return
        }
        if activeItems[idx].title == settingsKey {
            print("[ReorderManager] moveItemUp => Attempting to move Settings. Aborted.")
            return
        }
        if activeItems[idx - 1].title == settingsKey {
            print("[ReorderManager] moveItemUp => Next item is Settings. Aborted.")
            return
        }
        
        print("[ReorderManager] Swapping item at index \(idx) with index \(idx - 1).")
        activeItems.swapAt(idx, idx - 1)
        updateSortOrders()
    }
    
    // MARK: - Move Item Down
    public func moveItemDown(_ title: String) {
        print("[ReorderManager] moveItemDown called for title: \(title)")
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else {
            print("[ReorderManager] moveItemDown => Item not found.")
            return
        }
        guard idx < activeItems.count - 1 else {
            print("[ReorderManager] moveItemDown => Already at bottom or invalid index.")
            return
        }
        if activeItems[idx].title == settingsKey {
            print("[ReorderManager] moveItemDown => Attempting to move Settings. Aborted.")
            return
        }
        if activeItems[idx + 1].title == settingsKey {
            print("[ReorderManager] moveItemDown => Next item is Settings. Aborted.")
            return
        }
        
        print("[ReorderManager] Swapping item at index \(idx) with index \(idx + 1).")
        activeItems.swapAt(idx, idx + 1)
        updateSortOrders()
    }
    
    // MARK: - Toggle Hidden
    public func toggleHidden(_ title: String) {
        print("[ReorderManager] toggleHidden called for title: \(title)")
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else {
            print("[ReorderManager] toggleHidden => Item not found.")
            return
        }
        if activeItems[idx].title == settingsKey {
            print("[ReorderManager] toggleHidden => Attempting to toggle Settings. Aborted.")
            return
        }
        
        activeItems[idx].isHidden.toggle()
        print("[ReorderManager] toggleHidden => isHidden now: \(activeItems[idx].isHidden) for title: \(title)")
    }
    
    // MARK: - Update Sort Orders
    // Recompute order after a move
    private func updateSortOrders() {
        print("[ReorderManager] updateSortOrders called. Recomputing sortOrder for each item.")
        for i in activeItems.indices {
            if activeItems[i].title == settingsKey {
                activeItems[i].sortOrder = 9999
                print("[ReorderManager] updateSortOrders => 'Settings' pinned at sortOrder = 9999")
            } else {
                activeItems[i].sortOrder = i
                print("[ReorderManager] updateSortOrders => Item: \(activeItems[i].title), new sortOrder: \(i)")
            }
        }
        
        print("[ReorderManager] Resorting activeItems by sortOrder.")
        activeItems.sort { $0.sortOrder < $1.sortOrder }
        print("[ReorderManager] updateSortOrders completed.")
    }
}
