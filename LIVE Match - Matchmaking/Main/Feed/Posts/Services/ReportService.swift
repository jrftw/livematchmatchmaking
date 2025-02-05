//
//  ReportService.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/5/25.
//

// MARK: - ReportService.swift
// Handles reporting a post.

import Foundation
import Firebase
import SwiftUI

public class ReportService {
    // MARK: - Shared
    public static let shared = ReportService()
    
    private init() {}
    
    // MARK: - Store Report
    public func reportPost(postId: String?, reason: String, completion: @escaping (Bool) -> Void) {
        guard let postId = postId else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let reportRef = db.collection("reports").document()
        
        let reportData: [String: Any] = [
            "postId": postId,
            "reason": reason,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        reportRef.setData(reportData) { error in
            if let error = error {
                print("Error saving report: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // MARK: - In-App Web Form
    public func reportPostView(title: String = "Report Post") -> some View {
        let formURLString = "https://forms.gle/xz3UdV2WqEN4sSaS7"
        return WebLinkView(title: title, urlString: formURLString)
    }
}
