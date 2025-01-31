//
//  LoginView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Basic login screen with username/email/phone support.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var credential = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isGuest = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Log In").font(.largeTitle)
                
                TextField("Email / Phone / Username", text: $credential)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Log In") {
                    logInAction()
                }
                .padding(.vertical, 8)
                
                Button("Forgot Password?") {
                    resetPassword()
                }
                
                Button("Sign Up") {
                    // Present sign-up logic if needed
                }
                .padding(.vertical, 8)
                
                Button("Continue as Guest") {
                    isGuest = true
                    AuthManager.shared.signInAsGuest()
                }
                
                NavigationLink("", destination: MainMenuView(), isActive: $isGuest)
                    .hidden()
            }
            .padding()
            .navigationTitle("Log In")
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func logInAction() {
        resolveCredential(credential) { resolvedEmail in
            guard let email = resolvedEmail, !email.isEmpty else {
                errorMessage = "Could not resolve login credential."
                showingError = true
                return
            }
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showingError = true
                } else {
                    print("Logged in successfully!")
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !credential.isEmpty else {
            errorMessage = "Enter your email/phone/username before resetting."
            showingError = true
            return
        }
        resolveCredential(credential) { resolvedEmail in
            guard let email = resolvedEmail, !email.isEmpty else {
                errorMessage = "Could not resolve login credential for password reset."
                showingError = true
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = "Password reset email sent."
                }
                showingError = true
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
