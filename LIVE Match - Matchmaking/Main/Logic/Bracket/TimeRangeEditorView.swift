// MARK: TimeRangeEditorView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// -------------------------------------------------------
// A small row that lets the user pick start/end times for a single interval.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct TimeRangeEditorView: View {
    @Binding var range: TimeRange
    var onRemove: (() -> Void)?
    
    var body: some View {
        HStack {
            DatePicker("", selection: $range.start, displayedComponents: .hourAndMinute)
                .labelsHidden()
            Text("-")
            DatePicker("", selection: $range.end, displayedComponents: .hourAndMinute)
                .labelsHidden()
            
            Spacer()
            
            Button(action: { onRemove?() }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}
