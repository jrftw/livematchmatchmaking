// MARK: CreatorAvailabilityView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
//
// Manages user availability with 15-min slots per day
// displayed in 12-hour (AM/PM) format. Also uses LocationRegionDetector
// to guess local time zone.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorAvailabilityView: View {
    @StateObject private var locationDetector = LocationRegionDetector()
    
    // Each day => 96 slots of 15 minutes (00:00..23:45).
    // Key = weekday, value = a set of slot indices that are "selected."
    @State private var availability: [String: Set<Int>] = [
        "Monday": [], "Tuesday": [], "Wednesday": [],
        "Thursday": [], "Friday": [], "Saturday": [], "Sunday": []
    ]
    
    private let daysOfWeek = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    private let slotCount = 96  // 24 * 4 = 96
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                timeZoneSection()
                
                // Show availability toggles for each day
                ForEach(daysOfWeek, id: \.self) { day in
                    dayAvailabilitySection(day)
                }
            }
            .navigationTitle("Availability")
            .onAppear {
                locationDetector.requestLocationPermission()
            }
        }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension CreatorAvailabilityView {
    private func timeZoneSection() -> some View {
        Section("Time Zone") {
            Text("Detected Time Zone: \(locationDetector.detectedTimeZone ?? "Unknown")")
                .foregroundColor(locationDetector.detectedTimeZone == nil ? .secondary : .primary)
            
            Button("Refresh Location") {
                locationDetector.requestLocationPermission()
            }
        }
    }
    
    private func dayAvailabilitySection(_ day: String) -> some View {
        Section(day) {
            // Convert the stride to an Array for ForEach
            let slotsPerRow = 4
            let rowIndices = Array(stride(from: 0, to: slotCount, by: slotsPerRow))
            
            ForEach(rowIndices, id: \.self) { startIndex in
                HStack {
                    ForEach(0..<slotsPerRow, id: \.self) { offset in
                        let slotIndex = startIndex + offset
                        if slotIndex < slotCount {
                            slotToggle(day, slotIndex: slotIndex)
                        } else {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    private func slotToggle(_ day: String, slotIndex: Int) -> some View {
        let minutesTotal = slotIndex * 15
        let hh24 = minutesTotal / 60
        let mm = minutesTotal % 60
        
        let label = formatTime12Hour(hh24: hh24, mm: mm)
        
        return Toggle(label, isOn: Binding<Bool>(
            get: { availability[day]?.contains(slotIndex) ?? false },
            set: { isOn in
                if isOn {
                    availability[day]?.insert(slotIndex)
                } else {
                    availability[day]?.remove(slotIndex)
                }
            }
        ))
        .toggleStyle(.button)
        .frame(maxWidth: .infinity)
        .font(.footnote)
    }
    
    private func formatTime12Hour(hh24: Int, mm: Int) -> String {
        var suffix = "AM"
        var hour12 = hh24
        
        switch hour12 {
        case 0:
            hour12 = 12
        case 12:
            suffix = "PM"
        case 13...23:
            hour12 -= 12
            suffix = "PM"
        default:
            break
        }
        
        return String(format: "%d:%02d %@", hour12, mm, suffix)
    }
}
