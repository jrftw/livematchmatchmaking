//
//  CSVTemplateDownloadView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


//
//  CSVTemplateDownloadView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: CSVTemplateDownloadView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Presents a button to download/share a bracket CSV template.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct CSVTemplateDownloadView: View {
    @State private var showShare = false
    @State private var shareURL: URL?
    
    private let templateCSVContent = """
username,email,phone,platformUsername,discordUsername,daysOfWeekAvailable,timesAvailable,timezone,networkOrAgency,maxBracketMatches,maxMatchesPerDay,averageDiamondAmount,preferredOpponents,excludedOpponents,additionalNotes
CreatorOne,one@mail.com,555-1111,CreatorOne_TikTok,CreatorOne#0001,"Monday|Wednesday","Afternoons","Pacific Time (PST/PDT) – UTC-8 or UTC-7 (DST)","Agency",5,2,100,"CreatorTwo","",Sample bracket notes
CreatorTwo,two@mail.com,555-2222,CreatorTwo_YouNow,CreatorTwo#2222,"Tuesday|Thursday","Evenings","Eastern Time (EST/EDT) – UTC-5 or UTC-4 (DST)","Creator Network",5,2,50,"CreatorOne","","Another sample
"""

    var body: some View {
        Button("Download Template CSV") {
            prepareAndShareCSV()
        }
    }
    
    private func prepareAndShareCSV() {
        let filename = "BracketTemplate.csv"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try templateCSVContent.write(to: fileURL, atomically: true, encoding: .utf8)
            shareURL = fileURL
            showShare = true
        } catch {
            print("Error writing CSV template: \(error)")
        }
    }
}

@available(iOS 15.6, *)
extension CSVTemplateDownloadView {
    func shareSheetView(for url: URL) -> some View {
        ShareSheetActivityView(activityItems: [url])
    }
}

#if os(iOS)
import UIKit

@available(iOS 15.6, *)
struct ShareSheetActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif