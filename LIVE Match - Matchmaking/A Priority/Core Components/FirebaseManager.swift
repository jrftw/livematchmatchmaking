// -----------------------------------------------------------------------------
// MARK: FirebaseManager.swift
// Shared Firestore reference; ensure FirebaseApp.configure() is called in app startup.
// -----------------------------------------------------------------------------
import FirebaseFirestore
import Firebase

public class FirebaseManager {
    public static let shared = FirebaseManager()
    public let db: Firestore
    
    private init() {
        // Make sure you call FirebaseApp.configure() in your AppDelegate/SceneDelegate or main entry
        db = Firestore.firestore()
    }
}
