// MARK: ReorderManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ReorderManager: ObservableObject {
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
    
    @Published public private(set) var activeItems: [ReorderableMenuItem] = []
    private let settingsKey = "Settings"
    
    public init() {}
    
    func loadItems(with items: [MainMenuView.MenuItem]) {
        var reorderables: [ReorderableMenuItem] = []
        for (index, raw) in items.enumerated() {
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
    
    func moveItemUp(_ title: String) {
        guard let index = activeItems.firstIndex(where: { $0.title == title }) else { return }
        if activeItems[index].title == settingsKey { return }
        guard index > 0 else { return }
        
        if activeItems[index - 1].title == settingsKey { return }
        
        activeItems.swapAt(index, index - 1)
        updateSortOrders()
    }
    
    func moveItemDown(_ title: String) {
        guard let index = activeItems.firstIndex(where: { $0.title == title }) else { return }
        if activeItems[index].title == settingsKey { return }
        guard index < activeItems.count - 1 else { return }
        
        if activeItems[index + 1].title == settingsKey { return }
        
        activeItems.swapAt(index, index + 1)
        updateSortOrders()
    }
    
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
