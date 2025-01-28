//
//  TimeZonePickerView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  TimeZonePickerView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: TimeZonePickerView.swift
// MARK: iOS 15.6+, macOS 11.5, visionOS 2.0+
// Presents a list of common time zones for user selection (US, Canada, Mexico, China, etc.).

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TimeZonePickerView: View {
    @Binding var currentSelection: String
    
    // Predefined zones grouped by region
    private let regions: [TimeZoneRegion] = [
        TimeZoneRegion(
            regionName: "United States",
            zones: [
                "Hawaii-Aleutian Time (HST) – UTC-10",
                "Alaska Time (AKST/AKDT) – UTC-9 or UTC-8 (DST)",
                "Pacific Time (PST/PDT) – UTC-8 or UTC-7 (DST)",
                "Mountain Time (MST/MDT) – UTC-7 or UTC-6 (DST)",
                "Central Time (CST/CDT) – UTC-6 or UTC-5 (DST)",
                "Eastern Time (EST/EDT) – UTC-5 or UTC-4 (DST)",
                "Atlantic Time (AST/ADT) – UTC-4 or UTC-3 (DST)"
            ]
        ),
        TimeZoneRegion(
            regionName: "Canada",
            zones: [
                "Pacific Time (PST/PDT) – UTC-8 or UTC-7 (DST)",
                "Mountain Time (MST/MDT) – UTC-7 or UTC-6 (DST)",
                "Central Time (CST/CDT) – UTC-6 or UTC-5 (DST)",
                "Eastern Time (EST/EDT) – UTC-5 or UTC-4 (DST)",
                "Atlantic Time (AST/ADT) – UTC-4 or UTC-3 (DST)",
                "Newfoundland Time (NST/NDT) – UTC-3:30 or UTC-2:30 (DST)"
            ]
        ),
        TimeZoneRegion(
            regionName: "Mexico",
            zones: [
                "Northwest Zone (Pacific Time) – UTC-8 or UTC-7 (DST)",
                "Pacific Zone (Mountain Time) – UTC-7 or UTC-6 (DST)",
                "Central Zone (Central Time) – UTC-6 or UTC-5 (DST)",
                "Southeastern Zone (Quintana Roo) – UTC-5 (no DST)"
            ]
        ),
        TimeZoneRegion(
            regionName: "China",
            zones: [
                "China Standard Time (CST) – UTC+8 (single national time zone)"
            ]
        ),
        TimeZoneRegion(
            regionName: "Singapore",
            zones: [
                "Singapore Standard Time (SGT) – UTC+8 (single national time zone)"
            ]
        ),
        TimeZoneRegion(
            regionName: "Europe",
            zones: [
                "Western European Time (WET/GMT) – UTC or UTC+1 (DST)",
                "Central European Time (CET) – UTC+1 or UTC+2 (DST)",
                "Eastern European Time (EET) – UTC+2 or UTC+3 (DST)"
            ]
        )
    ]
    
    var body: some View {
        List {
            ForEach(regions, id: \.regionName) { region in
                Section(header: Text(region.regionName)) {
                    ForEach(region.zones, id: \.self) { zone in
                        Button {
                            currentSelection = zone
                        } label: {
                            HStack {
                                Text(zone)
                                    .foregroundColor(.primary)
                                Spacer()
                                if zone == currentSelection {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Timezone")
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TimeZoneRegion {
    let regionName: String
    let zones: [String]
}