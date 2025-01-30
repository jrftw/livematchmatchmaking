//
//  TimeAvailabilityView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: TimeAvailabilityView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays a 12-hour format time selector with 15-min increments.
// The user can toggle each time slot to mark availability.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TimeAvailabilityView: View {
    @Binding var selectedTimeSlots: Set<String>
    
    var body: some View {
        List {
            ForEach(allTimeSlots, id: \.self) { slot in
                #if os(iOS)
                Toggle(slot, isOn: Binding(
                    get: { selectedTimeSlots.contains(slot) },
                    set: { newValue in
                        if newValue {
                            selectedTimeSlots.insert(slot)
                        } else {
                            selectedTimeSlots.remove(slot)
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle())  // iOS uses switch
                #else
                Toggle(slot, isOn: Binding(
                    get: { selectedTimeSlots.contains(slot) },
                    set: { newValue in
                        if newValue {
                            selectedTimeSlots.insert(slot)
                        } else {
                            selectedTimeSlots.remove(slot)
                        }
                    }
                ))
                .toggleStyle(DefaultToggleStyle()) // macOS/visionOS fallback
                #endif
            }
        }
        .navigationTitle("Select Time Availability")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Private Helpers
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension TimeAvailabilityView {
    private var allTimeSlots: [String] {
        var slots: [String] = []
        for minutes in stride(from: 0, through: 1439, by: 15) {
            let hour = (minutes / 60) % 12
            let minute = minutes % 60
            let isPM = (minutes / 60) >= 12
            
            let displayHour = (hour == 0) ? 12 : hour
            let displayMinute = String(format: "%02d", minute)
            let ampm = isPM ? "PM" : "AM"
            
            let slot = "\(displayHour):\(displayMinute) \(ampm)"
            slots.append(slot)
        }
        return slots
    }
}
