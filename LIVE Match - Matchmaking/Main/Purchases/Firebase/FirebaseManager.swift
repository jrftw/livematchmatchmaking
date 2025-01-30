// MARK: FirebaseManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Provides a global Firestore reference.

import Firebase
import FirebaseFirestore

public final class FirebaseManager {
    public static let shared = FirebaseManager()
    private init() {}
    
    public var db: Firestore {
        Firestore.firestore()
    }
}
