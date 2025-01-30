// MARK: File: SimpleAuthView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A unified, user-friendly Sign In / Sign Up / Forgot Password flow.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
enum AuthFlowMode: String, CaseIterable {
    case signIn = "Sign In"
    case signUp = "Sign Up"
    case forgot = "Forgot Password"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct SimpleAuthView: View {
    @State private var mode: AuthFlowMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $mode) {
                    ForEach(AuthFlowMode.allCases, id: \.self) { flow in
                        Text(flow.rawValue).tag(flow)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Group {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)
                    
                    if mode != .forgot {
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 8)
                    }
                    if mode == .signUp {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
                
                Button(action: handleAction) {
                    Text(actionButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
            }
            .navigationTitle("Account")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var actionButtonTitle: String {
        switch mode {
        case .signIn: return "Sign In"
        case .signUp: return "Sign Up"
        case .forgot: return "Reset Password"
        }
    }
    
    private func handleAction() {
        switch mode {
        case .signIn:
            AuthManager.shared.signIn(email: email, password: password) { result in
                switch result {
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                case .success:
                    break
                }
            }
            
        case .signUp:
            guard password == confirmPassword, !password.isEmpty else {
                alertMessage = "Passwords don't match."
                showingAlert = true
                return
            }
            AuthManager.shared.signUp(email: email, password: password) { result in
                switch result {
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                case .success:
                    break
                }
            }
            
        case .forgot:
            guard !email.isEmpty else {
                alertMessage = "Enter your email."
                showingAlert = true
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                } else {
                    alertMessage = "Password reset email sent."
                }
                showingAlert = true
            }
        }
    }
}
