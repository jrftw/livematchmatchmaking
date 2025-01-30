//
//  LoginView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Basic login screen with an option for guest mode.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isGuest = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Log In").font(.largeTitle)
                
                TextField("Email", text: $email)
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
                    // Could show SignUpView or present sign-up logic
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
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showingError = true
            } else {
                print("Logged in successfully!")
            }
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Enter your email before resetting."
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
