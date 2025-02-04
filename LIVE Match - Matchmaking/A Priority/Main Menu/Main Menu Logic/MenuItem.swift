//
//  MenuItem.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/2/25.
//


//
//  MenuItem.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A single item in the main menu, with optional 'isHidden' flag.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MenuItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let icon: String
    public let color: Color
    public let destination: AnyView
    
    public var isHidden: Bool = false
    
    public init(title: String, icon: String, color: Color, destination: AnyView) {
        self.title = title
        self.icon = icon
        self.color = color
        self.destination = destination
    }
}