//
//  LoginView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - LoginView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Alternative basic login screen with username/email/phone support.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LoginView: View {
    // MARK: - State
    @State private var credential = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isGuest = false
    
    // MARK: - Body
    public var body: some View {
        print("[LoginView] body invoked. Building NavigationView for login UI.")
        
        return NavigationView {
            VStack(spacing: 20) {
                Text("Log In")
                    .font(.largeTitle)
                
                TextField("Email / Phone / Username", text: $credential)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Log In") {
                    print("[LoginView] 'Log In' button tapped.")
                    logInAction()
                }
                .padding(.vertical, 8)
                
                Button("Forgot Password?") {
                    print("[LoginView] 'Forgot Password?' button tapped.")
                    resetPassword()
                }
                
                Button("Sign Up") {
                    print("[LoginView] 'Sign Up' button tapped. Present sign-up flow if needed.")
                    // Example: Navigation to a signup flow
                }
                .padding(.vertical, 8)
                
                Button("Continue as Guest") {
                    print("[LoginView] 'Continue as Guest' button tapped.")
                    isGuest = true
                    AuthManager.shared.signInAsGuest()
                    print("[LoginView] isGuest set to true => Navigation triggered.")
                }
                
                NavigationLink("", destination: MainMenuView(), isActive: $isGuest)
                    .hidden()
            }
            .padding()
            .navigationTitle("Log In")
            .alert(isPresented: $showingError) {
                print("[LoginView] Showing error alert => \(errorMessage)")
                return Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Log In Action
    private func logInAction() {
        print("[LoginView] logInAction called.")
        print("[LoginView] Attempting to resolve credential => \(credential)")
        
        resolveCredential(credential) { resolvedEmail in
            print("[LoginView] resolveCredential completion triggered.")
            guard let email = resolvedEmail, !email.isEmpty else {
                print("[LoginView] Could not resolve credential. Displaying error.")
                errorMessage = "Could not resolve login credential."
                showingError = true
                return
            }
            
            print("[LoginView] Credential resolved as => \(email). Calling Auth signIn.")
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                print("[LoginView] signIn completion triggered.")
                
                if let error = error {
                    print("[LoginView] Login failed => \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showingError = true
                } else {
                    print("[LoginView] Logged in successfully.")
                }
            }
        }
    }
    
    // MARK: - Reset Password
    private func resetPassword() {
        print("[LoginView] resetPassword called.")
        print("[LoginView] Checking credential before reset => \(credential)")
        
        guard !credential.isEmpty else {
            print("[LoginView] Credential is empty. Displaying error.")
            errorMessage = "Enter your email/phone/username before resetting."
            showingError = true
            return
        }
        
        print("[LoginView] Attempting to resolve credential for password reset.")
        resolveCredential(credential) { resolvedEmail in
            print("[LoginView] resolveCredential (reset) completion triggered.")
            
            guard let email = resolvedEmail, !email.isEmpty else {
                print("[LoginView] Could not resolve credential for reset. Displaying error.")
                errorMessage = "Could not resolve login credential for reset."
                showingError = true
                return
            }
            
            print("[LoginView] Resolved email => \(email). Sending password reset request.")
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                print("[LoginView] sendPasswordReset completion triggered.")
                
                if let error = error {
                    print("[LoginView] Password reset failed => \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                } else {
                    print("[LoginView] Password reset email sent.")
                    errorMessage = "Password reset email sent."
                }
                showingError = true
            }
        }
    }
    
    // MARK: - Resolve Credential
    private func resolveCredential(_ credential: String, completion: @escaping (String?) -> Void) {
        print("[LoginView] resolveCredential called => \(credential)")
        
        if credential.contains("@") {
            print("[LoginView] Credential is an email. Returning immediately => \(credential)")
            completion(credential)
            return
        }
        
        let db = Firestore.firestore()
        print("[LoginView] Checking Firestore for 'username' match => \(credential)")
        
        db.collection("users")
            .whereField("username", isEqualTo: credential)
            .getDocuments { snapshot, error in
                print("[LoginView] Firestore username query completed.")
                
                if let error = error {
                    print("[LoginView] Error => \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let docs = snapshot?.documents, !docs.isEmpty,
                   let email = docs[0].data()["email"] as? String {
                    print("[LoginView] Username match found => \(email)")
                    completion(email)
                } else {
                    print("[LoginView] No username match => Checking phone => \(credential)")
                    db.collection("users")
                        .whereField("phone", isEqualTo: credential)
                        .getDocuments { snap2, err2 in
                            print("[LoginView] Firestore phone query completed.")
                            
                            if let err2 = err2 {
                                print("[LoginView] Error => \(err2.localizedDescription)")
                                completion(nil)
                                return
                            }
                            
                            if let docs2 = snap2?.documents, !docs2.isEmpty,
                               let email2 = docs2[0].data()["email"] as? String {
                                print("[LoginView] Phone match found => \(email2)")
                                completion(email2)
                            } else {
                                print("[LoginView] No phone match found => returning nil.")
                                completion(nil)
                            }
                        }
                }
            }
    }
}
