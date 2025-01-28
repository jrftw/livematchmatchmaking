//
//  Item.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
