// MARK: File 7: SignInView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Simplifies the flow so that "Sign Up" goes directly to ExtendedSignUpView (instead of ChooseAccountTypeView).

import SwiftUI
import FirebaseAuth

public struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Log In or Sign Up")
                .font(.title)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Log In") {
                AuthManager.shared.signIn(email: email, password: password) { result in
                    switch result {
                    case .failure(let err):
                        errorMessage = err.localizedDescription
                        showingError = true
                    case .success:
                        // Logged in successfully
                        break
                    }
                }
            }
            .padding(.vertical, 5)
            
            // MARK: Instead of showing "ChooseAccountTypeView," we show ExtendedSignUpView directly.
            Button("Sign Up") {
                showSignUp = true
            }
            .padding(.vertical, 5)
        }
        .padding()
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK")))
        }
        // Show ExtendedSignUpView as a sheet
        .sheet(isPresented: $showSignUp) {
            ExtendedSignUpView()
        }
    }
}
