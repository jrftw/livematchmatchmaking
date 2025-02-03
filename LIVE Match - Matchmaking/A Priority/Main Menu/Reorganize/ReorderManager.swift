//
//  ReorderManager.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Manages a list of MenuItem(s), allowing them to be rearranged or hidden.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class ReorderManager: ObservableObject {
    @Published public var activeItems: [MenuItem] = []
    
    public init() {}
    
    public func loadItems(with items: [MenuItem]) {
        self.activeItems = items
    }
    
    public func moveItemUp(_ title: String) {
        guard let idx = activeItems.firstIndex(where: { $0.title == title }),
              idx > 0 else { return }
        activeItems.swapAt(idx, idx - 1)
    }
    
    public func moveItemDown(_ title: String) {
        guard let idx = activeItems.firstIndex(where: { $0.title == title }),
              idx < activeItems.count - 1 else { return }
        activeItems.swapAt(idx, idx + 1)
    }
    
    public func toggleHidden(_ title: String) {
        guard let idx = activeItems.firstIndex(where: { $0.title == title }) else { return }
        activeItems[idx].isHidden.toggle()
    }
}
