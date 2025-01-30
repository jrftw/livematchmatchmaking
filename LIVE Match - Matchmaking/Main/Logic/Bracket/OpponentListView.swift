//
//  OpponentListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  OpponentListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: OpponentListView.swift
// MARK: iOS 15.6+, macOS 11.5, visionOS 2.0+
// A dynamic list for "preferredOpponents" or "excludedOpponents."

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct OpponentListView: View {
    @Binding var opponents: [String]
    let label: String
    
    @State private var newOpponent = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(opponents, id: \.self) { opp in
                Text(opp)
            }
            HStack {
                TextField(label, text: $newOpponent)
                Button("Add") {
                    guard !newOpponent.isEmpty else { return }
                    opponents.append(newOpponent)
                    newOpponent = ""
                }
            }
        }
    }
}