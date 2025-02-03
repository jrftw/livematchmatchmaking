//
//  LoginView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Lets users log in with Email, Username, or Phone. Guest option moves them to .menu or the main flow.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct LoginView: View {
    // MARK: - Binding
    @Binding var selectedScreen: MainScreen
    
    // MARK: - State
    @State private var credential = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isGuest = false
    
    // MARK: - Init
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Log In")
                    .font(.largeTitle)
                
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
                    // Example: Switch to a sign-up flow or screen
                    // selectedScreen = .profile or something else if needed
                }
                .padding(.vertical, 8)
                
                Button("Continue as Guest") {
                    isGuest = true
                    AuthManager.shared.signInAsGuest()
                }
                
                // Navigate if isGuest == true => main flow
                NavigationLink(
                    "",
                    destination: MainMenuView(selectedScreen: $selectedScreen),
                    isActive: $isGuest
                )
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
}

// MARK: - Private Methods
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension LoginView {
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
                    // On success, navigate to e.g. .menu
                    selectedScreen = .menu
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !credential.isEmpty else {
            errorMessage = "Enter your email/phone/username first."
            showingError = true
            return
        }
        resolveCredential(credential) { resolvedEmail in
            guard let email = resolvedEmail, !email.isEmpty else {
                errorMessage = "Could not resolve login credential for reset."
                showingError = true
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { err in
                if let err = err {
                    errorMessage = err.localizedDescription
                } else {
                    errorMessage = "Password reset email sent."
                }
                showingError = true
            }
        }
    }
    
    /// Resolves a given credential (username, phone, or email) into an email address for Firebase Auth.
    private func resolveCredential(_ credential: String, completion: @escaping (String?) -> Void) {
        // If user typed an '@', assume email
        if credential.contains("@") {
            completion(credential)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: credential)
            .getDocuments { snap, err in
                if let err = err {
                    completion(nil)
                    return
                }
                if let docs = snap?.documents, !docs.isEmpty,
                   let email = docs[0].data()["email"] as? String {
                    completion(email)
                } else {
                    // Next, check if credential is a phone
                    db.collection("users")
                        .whereField("phone", isEqualTo: credential)
                        .getDocuments { snap2, err2 in
                            if let err2 = err2 {
                                completion(nil)
                                return
                            }
                            if let docs2 = snap2?.documents, !docs2.isEmpty,
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
