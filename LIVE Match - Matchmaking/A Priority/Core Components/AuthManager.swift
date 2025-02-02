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
    
    // MARK: - Initialization
    private init() {
        print("[AuthManager] init called. Adding Auth state listener.")
        authListener = Auth.auth().addStateDidChangeListener { _, newUser in
            print("[AuthManager] Auth state changed. newUser: \(newUser?.email ?? "nil")")
            self.user = newUser
        }
        print("[AuthManager] init completed. Current user: \(user?.email ?? "nil")")
    }
    
    // MARK: - Sign Up
    public func signUp(email: String, password: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        print("[AuthManager] signUp called with email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            print("[AuthManager] signUp completion triggered.")
            if let error = error {
                print("[AuthManager] signUp error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[AuthManager] signUp successful for email: \(email)")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Sign In
    public func signIn(email: String, password: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        print("[AuthManager] signIn called with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            print("[AuthManager] signIn completion triggered.")
            if let error = error {
                print("[AuthManager] signIn error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[AuthManager] signIn successful for email: \(email)")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Sign In as Guest
    public func signInAsGuest() {
        print("[AuthManager] signInAsGuest called.")
        isGuest = true
        print("[AuthManager] signInAsGuest completed. isGuest = \(isGuest)")
    }
    
    // MARK: - Sign Out
    public func signOut() {
        print("[AuthManager] signOut called.")
        do {
            try Auth.auth().signOut()
            isGuest = false
            print("[AuthManager] signOut successful. isGuest reset to \(isGuest)")
        } catch {
            print("[AuthManager] signOut error: \(error.localizedDescription)")
        }
    }
}
