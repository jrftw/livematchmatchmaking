//
//  AuthManager.swift
//  LIVE Match - Matchmaking
//
//  Minimal authentication logic with a guest option.
//  Monitors changes to Firebase Auth user state and updates accordingly.
//

import SwiftUI
import FirebaseAuth

public final class AuthManager: ObservableObject {
    // MARK: - Shared Instance
    public static let shared = AuthManager()
    
    // MARK: - Published Properties
    @Published public var user: User? = Auth.auth().currentUser
    @Published public var isGuest: Bool = false
    
    // MARK: - Private
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Init
    private init() {
        authListener = Auth.auth().addStateDidChangeListener { _, newUser in
            self.user = newUser
        }
    }
    
    // MARK: - Sign Up
    public func signUp(email: String, password: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.isGuest = false
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Sign In
    public func signIn(email: String, password: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.isGuest = false
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Guest Sign In
    public func signInAsGuest() {
        isGuest = true
        user = nil
    }
    
    // MARK: - Sign Out
    public func signOut() {
        do {
            try Auth.auth().signOut()
            isGuest = false
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
}
