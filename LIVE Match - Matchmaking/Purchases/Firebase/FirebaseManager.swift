//
//  FirebaseManager.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Shared Firebase Firestore reference.
//

import Foundation
import FirebaseFirestore

public class FirebaseManager {
    public static let shared = FirebaseManager()
    
    public let db: Firestore
    
    private init() {
        db = Firestore.firestore()
    }
}
