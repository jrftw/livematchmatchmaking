//
//  SignInView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Modern sign-in screen supporting Username, Email, or Phone Number.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var credential = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    public init() {}
    
    public var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Log In or Sign Up")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                TextField("Email / Phone / Username", text: $credential)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Log In") {
                    signInAction()
                }
                .font(.headline)
                .padding(.vertical, 8)
                
                Button("Sign Up") {
                    showSignUp = true
                }
                .font(.headline)
                .padding(.vertical, 5)
            }
            .padding()
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                gradient: Gradient(colors: [.black, .gray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.white, Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func signInAction() {
        resolveCredential(credential) { resolvedEmail in
            guard let email = resolvedEmail, !email.isEmpty else {
                errorMessage = "Could not resolve login credential."
                showingError = true
                return
            }
            AuthManager.shared.signIn(email: email, password: password) { result in
                switch result {
                case .failure(let err):
                    errorMessage = err.localizedDescription
                    showingError = true
                case .success:
                    break
                }
            }
        }
    }
    
    private func resolveCredential(_ credential: String, completion: @escaping (String?) -> Void) {
        if credential.contains("@") {
            completion(credential)
            return
        }
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("username", isEqualTo: credential)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error resolving credential by username: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                if let docs = snapshot?.documents, !docs.isEmpty,
                   let email = docs[0].data()["email"] as? String {
                    completion(email)
                } else {
                    db.collection("users")
                        .whereField("phone", isEqualTo: credential)
                        .getDocuments { snapshot2, error2 in
                            if let error2 = error2 {
                                print("Error resolving credential by phone: \(error2.localizedDescription)")
                                completion(nil)
                                return
                            }
                            if let docs2 = snapshot2?.documents, !docs2.isEmpty,
                               let email2 = docs2[0].data()["email"] as? String {
                                completion(email2)
                            } else {
                                completion(nil)
                            }
                        }
                }
            }
    }
}
