// MARK: TimesByDayAvailabilityView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// -------------------------------------------------------
// Displays a day-by-day list, each with multiple [TimeRange] intervals
// without force-unwrapping the optional dictionary access.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TimesByDayAvailabilityView: View {
    @Binding var timesByDay: [String: [TimeRange]]
    
    // Example: All 7 days for demonstration
    private let daysOfWeek = [
        "Sunday", "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday"
    ]
    
    var body: some View {
        ForEach(daysOfWeek, id: \.self) { day in
            Section(day) {
                let intervals = timesByDay[day] ?? []
                
                // Use 'ForEach' over 0..<intervals.count, then create a custom Binding for each index.
                ForEach(0..<intervals.count, id: \.self) { idx in
                    TimeRangeEditorView(
                        // Create a custom binding that reads/writes the correct array index
                        range: Binding(
                            get: { intervals[idx] }, // read from local 'intervals'
                            set: { newVal in
                                // write back into 'timesByDay[day, default: []]'
                                // so we don't force-unwrap
                                timesByDay[day, default: []][idx] = newVal
                            }
                        ),
                        onRemove: {
                            // remove this index from the dictionary array
                            timesByDay[day, default: []].remove(at: idx)
                            // if no more intervals remain, remove the key entirely
                            if timesByDay[day, default: []].isEmpty {
                                timesByDay.removeValue(forKey: day)
                            }
                        }
                    )
                }
                
                Button("Add Time Interval") {
                    addTimeRange(for: day)
                }
            }
        }
    }
    
    private func addTimeRange(for day: String) {
        let newRange = TimeRange(
            start: Date(),
            end: Date().addingTimeInterval(3600)
        )
        // Safely append to the array with a default empty array
        timesByDay[day, default: []].append(newRange)
    }
}
