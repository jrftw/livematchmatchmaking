//
//  FillInSharesheetActivityView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
//  iOS 15.6+, visionOS 2.0+
//  A simple share sheet for exporting items like CSV/XLSX files.

#if os(iOS)
import SwiftUI
import UIKit

// MARK: - FillInSharesheetActivityView
@available(iOS 15.6, *)
public struct FillInSharesheetActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    public init(activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
#endif
