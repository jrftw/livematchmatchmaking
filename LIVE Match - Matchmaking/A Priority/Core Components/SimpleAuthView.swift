//
//  SimpleAuthView.swift
//  LIVE Match - Matchmaking
//
//  Alternate sign in / sign up UI. Now includes a "Continue as Guest" button
//  to demonstrate isGuest usage in AuthManager.
//
import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
enum AuthFlowMode: String, CaseIterable {
    case signIn = "Sign In"
    case signUp = "Sign Up"
    case forgot = "Forgot Password"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SimpleAuthView: View {
    @State private var mode: AuthFlowMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Picker("Mode", selection: $mode) {
                    ForEach(AuthFlowMode.allCases, id: \.self) { flow in
                        Text(flow.rawValue).tag(flow)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Email / Username / Phone
                if mode != .forgot {
                    TextField("Email / Username / Phone", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                } else {
                    // Forgot Mode sometimes only needs an email field
                    TextField("Enter Email / Username / Phone", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                // Password fields except for forgot
                if mode != .forgot {
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if mode == .signUp {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                }
                
                Button(action: handleAction) {
                    Text(actionButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // "Continue as Guest" below
                if mode != .forgot {
                    Button(action: {
                        AuthManager.shared.signInAsGuest()
                    }) {
                        Text("Continue as Guest")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Account")
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Notice"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private var actionButtonTitle: String {
        switch mode {
        case .signIn:
            return "Sign In"
        case .signUp:
            return "Sign Up"
        case .forgot:
            return "Reset Password"
        }
    }
    
    private func handleAction() {
        switch mode {
        case .signIn:
            guard !email.isEmpty, !password.isEmpty else {
                alertMessage = "Fill in Email & Password"
                showingAlert = true
                return
            }
            resolveLogin(email: email, password: password) { errMsg in
                if let err = errMsg {
                    alertMessage = err
                    showingAlert = true
                }
            }
        case .signUp:
            guard !email.isEmpty, !password.isEmpty else {
                alertMessage = "Fill in Email & Password"
                showingAlert = true
                return
            }
            guard password == confirmPassword else {
                alertMessage = "Passwords don't match."
                showingAlert = true
                return
            }
            resolveLogin(email: email, password: password) { errMsg in
                if let err = errMsg {
                    alertMessage = err
                    showingAlert = true
                }
            }
        case .forgot:
            guard !email.isEmpty else {
                alertMessage = "Enter email/phone/username to reset password."
                showingAlert = true
                return
            }
            resolvePasswordReset(credential: email) { errMsg in
                alertMessage = errMsg ?? "Password reset link sent."
                showingAlert = true
            }
        }
    }
    
    private func resolveLogin(email: String, password: String, completion: @escaping (String?) -> Void) {
        resolveCredential(email) { resolvedEmail in
            guard let finalEmail = resolvedEmail, !finalEmail.isEmpty else {
                completion("Could not resolve login credential.")
                return
            }
            if mode == .signUp {
                AuthManager.shared.signUp(email: finalEmail, password: password) { result in
                    switch result {
                    case .failure(let e): completion(e.localizedDescription)
                    case .success: completion(nil)
                    }
                }
            } else {
                AuthManager.shared.signIn(email: finalEmail, password: password) { result in
                    switch result {
                    case .failure(let e): completion(e.localizedDescription)
                    case .success: completion(nil)
                    }
                }
            }
        }
    }
    
    private func resolvePasswordReset(credential: String, completion: @escaping (String?) -> Void) {
        resolveCredential(credential) { resolvedEmail in
            guard let email = resolvedEmail, !email.isEmpty else {
                completion("Could not resolve credential for reset.")
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { err in
                if let e = err {
                    completion(e.localizedDescription)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func resolveCredential(_ credential: String, completion: @escaping (String?) -> Void) {
        // If it has '@' assume it's an email
        if credential.contains("@") {
            completion(credential)
            return
        }
        // Otherwise, check Firestore for username or phone
        let db = FirebaseManager.shared.db
        db.collection("users")
            .whereField("username", isEqualTo: credential)
            .getDocuments { snap, err in
                if let err = err {
                    completion("Username check error: \(err.localizedDescription)")
                    return
                }
                if let docs = snap?.documents, !docs.isEmpty,
                   let email = docs[0].data()["email"] as? String {
                    completion(email)
                } else {
                    db.collection("users")
                        .whereField("phoneNumber", isEqualTo: credential)
                        .getDocuments { snap2, err2 in
                            if let err2 = err2 {
                                completion("Phone check error: \(err2.localizedDescription)")
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
