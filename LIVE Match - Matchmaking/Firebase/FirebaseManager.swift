// MARK: File 3: FirebaseManager.swift
// Provides a global Firestore reference. Ensure FirebaseApp.configure() in your App.

import Firebase
import FirebaseFirestore

public final class FirebaseManager {
    public static let shared = FirebaseManager()
    private init() {}
    
    public var db: Firestore {
        Firestore.firestore()
    }
}
