//
//  AuthManager.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Handles Firebase Auth sign-up, sign-in, guest logic. Production-ready.
//

import SwiftUI
import FirebaseAuth

public final class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public var user: User? = Auth.auth().currentUser
    @Published public var isGuest: Bool = false
    
    private var authListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        authListener = Auth.auth().addStateDidChangeListener { _, newUser in
            self.user = newUser
        }
    }
    
    public func signUp(email: String, password: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    public func signIn(email: String, password: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    public func signInAsGuest() {
        isGuest = true
    }
    
    public func signOut() {
        do {
            try Auth.auth().signOut()
            isGuest = false
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
}
