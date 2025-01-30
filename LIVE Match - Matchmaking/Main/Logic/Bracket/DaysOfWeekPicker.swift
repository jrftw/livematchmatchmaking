//
//  DaysOfWeekPicker.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  DaysOfWeekPicker.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: DaysOfWeekPicker.swift
// MARK: iOS 15.6+, macOS 11.5, visionOS 2.0+
// Multi-select for days of the week (e.g., Monday through Sunday).

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct DaysOfWeekPicker: View {
    private let allDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    @Binding var selection: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(allDays, id: \.self) { day in
                Toggle(day, isOn: Binding(
                    get: { selection.contains(day) },
                    set: { isOn in
                        if isOn { selection.append(day) }
                        else { selection.removeAll { $0 == day } }
                    }
                ))
            }
        }
    }
}