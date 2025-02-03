//
//  CreatorAvailabilityView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//
//  Manages user Availability with 15-min slots per day,
//  showing times in 12-hour format (AM/PM) to be more user-friendly.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreatorAvailabilityView: View {
    @StateObject private var locationDetector = LocationRegionDetector()
    
    // Each day has 96 slots of 15 minutes (00:00..23:45).
    // Key is the weekday, value is a set of slot indices that are "selected" (available).
    @State private var availability: [String: Set<Int>] = [
        "Monday": [], "Tuesday": [], "Wednesday": [],
        "Thursday": [], "Friday": [], "Saturday": [], "Sunday": []
    ]
    
    private let daysOfWeek = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    private let slotCount = 96  // 24 hours * (60 / 15) = 96
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                timeZoneSection()
                
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

// MARK: - Subviews
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension CreatorAvailabilityView {
    
    // MARK: Time Zone
    private func timeZoneSection() -> some View {
        Section("Time Zone") {
            if let tz = locationDetector.detectedTimeZone {
                Text("Detected Time Zone: \(tz)")
            } else {
                Text("Time Zone: Unknown")
                    .foregroundColor(.secondary)
            }
            Button("Refresh Location") {
                locationDetector.requestLocationPermission()
            }
        }
    }
    
    // MARK: Day Section
    private func dayAvailabilitySection(_ day: String) -> some View {
        Section(day) {
            // We'll show 4 toggles per row.
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
    
    // MARK: Single Slot Toggle
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
    
    // MARK: 12-Hour Format Helper
    private func formatTime12Hour(hh24: Int, mm: Int) -> String {
        // Convert 24-hour to 12-hour with AM/PM suffix
        var suffix = "AM"
        var hour12 = hh24
        
        switch hour12 {
        case 0:
            hour12 = 12  // Midnight -> 12 AM
        case 12:
            suffix = "PM"  // 12:xx is PM
        case 13...23:
            hour12 -= 12
            suffix = "PM"
        default:
            // For 1..11, suffix remains "AM"
            break
        }
        
        return String(format: "%d:%02d %@", hour12, mm, suffix)
    }
}
