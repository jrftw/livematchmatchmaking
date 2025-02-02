//
//  SimpleAuthView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A user-friendly Sign In / Sign Up / Forgot Password flow (Alternate Option).
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
struct SimpleAuthView: View {
    // MARK: - State
    @State private var mode: AuthFlowMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    // MARK: - Init
    init() {
        print("[SimpleAuthView] init called.")
        print("[SimpleAuthView] Initial mode: \(mode), email: \(email), password: \(password), confirmPassword: \(confirmPassword)")
    }
    
    // MARK: - Body
    var body: some View {
        let _ = print("[SimpleAuthView] body invoked. Current mode: \(mode), email: \(email), password: \(password), confirmPassword: \(confirmPassword)")
        
        return NavigationView {
            let _ = print("[SimpleAuthView] Building main VStack.")
            
            VStack {
                let _ = print("[SimpleAuthView] Adding Picker for mode selection.")
                Picker("Mode", selection: $mode) {
                    ForEach(AuthFlowMode.allCases, id: \.self) { flow in
                        Text(flow.rawValue).tag(flow)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Group {
                    let _ = print("[SimpleAuthView] Adding TextField for email/username/phone.")
                    TextField("Email / Username / Phone", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)
                    
                    if mode != .forgot {
                        let _ = print("[SimpleAuthView] Mode != .forgot => Adding SecureField for password.")
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 8)
                    }
                    
                    if mode == .signUp {
                        let _ = print("[SimpleAuthView] Mode == .signUp => Adding SecureField for confirm password.")
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
                
                let _ = print("[SimpleAuthView] Adding Button for action: \(actionButtonTitle).")
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
                print("[SimpleAuthView] Showing alert with message: \(alertMessage)")
                return Alert(
                    title: Text("Notice"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Action Button Title
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
    
    // MARK: - Handle Action
    private func handleAction() {
        print("[SimpleAuthView] handleAction called. Current mode: \(mode)")
        
        switch mode {
        case .signIn:
            print("[SimpleAuthView] Mode: Sign In. Attempting resolveLogin.")
            resolveLogin(email: email, password: password) { errorMsg in
                if let err = errorMsg {
                    print("[SimpleAuthView] Sign In encountered error: \(err)")
                    alertMessage = err
                    showingAlert = true
                } else {
                    print("[SimpleAuthView] Sign In successful.")
                }
            }
            
        case .signUp:
            print("[SimpleAuthView] Mode: Sign Up. Checking password & confirmPassword match.")
            guard password == confirmPassword, !password.isEmpty else {
                print("[SimpleAuthView] Passwords do not match or empty. Showing alert.")
                alertMessage = "Passwords don't match."
                showingAlert = true
                return
            }
            print("[SimpleAuthView] Attempting resolveLogin for Sign Up.")
            resolveLogin(email: email, password: password) { err in
                if let e = err {
                    print("[SimpleAuthView] Sign Up encountered error: \(e)")
                    alertMessage = e
                    showingAlert = true
                } else {
                    print("[SimpleAuthView] Sign Up successful.")
                }
            }
            
        case .forgot:
            print("[SimpleAuthView] Mode: Forgot Password. Checking email field.")
            guard !email.isEmpty else {
                print("[SimpleAuthView] Email field empty. Showing alert.")
                alertMessage = "Enter your email/phone/username to reset."
                showingAlert = true
                return
            }
            print("[SimpleAuthView] Attempting resolvePasswordReset.")
            resolvePasswordReset(credential: email) { err in
                if let e = err {
                    print("[SimpleAuthView] Reset Password encountered error: \(e)")
                    alertMessage = e
                } else {
                    print("[SimpleAuthView] Reset Password request successful.")
                    alertMessage = "Password reset email sent."
                }
                showingAlert = true
            }
        }
    }
    
    // MARK: - Resolve Login
    private func resolveLogin(email: String, password: String, completion: @escaping (String?) -> Void) {
        print("[SimpleAuthView] resolveLogin called with email: \(email), password length: \(password.count)")
        
        resolveCredential(email) { resolvedEmail in
            print("[SimpleAuthView] resolveCredential returned: \(resolvedEmail ?? "nil")")
            
            guard let finalEmail = resolvedEmail, !finalEmail.isEmpty else {
                print("[SimpleAuthView] Could not resolve email. Returning error.")
                completion("Could not resolve login credential.")
                return
            }
            
            if mode == .signUp {
                print("[SimpleAuthView] Mode == .signUp => Calling AuthManager.signUp with \(finalEmail).")
                AuthManager.shared.signUp(email: finalEmail, password: password) { result in
                    print("[SimpleAuthView] AuthManager.signUp completion triggered.")
                    switch result {
                    case .failure(let error):
                        print("[SimpleAuthView] signUp failed: \(error.localizedDescription)")
                        completion(error.localizedDescription)
                    case .success:
                        print("[SimpleAuthView] signUp succeeded.")
                        completion(nil)
                    }
                }
            } else {
                print("[SimpleAuthView] Mode == .signIn => Calling AuthManager.signIn with \(finalEmail).")
                AuthManager.shared.signIn(email: finalEmail, password: password) { result in
                    print("[SimpleAuthView] AuthManager.signIn completion triggered.")
                    switch result {
                    case .failure(let error):
                        print("[SimpleAuthView] signIn failed: \(error.localizedDescription)")
                        completion(error.localizedDescription)
                    case .success:
                        print("[SimpleAuthView] signIn succeeded.")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Resolve Password Reset
    private func resolvePasswordReset(credential: String, completion: @escaping (String?) -> Void) {
        print("[SimpleAuthView] resolvePasswordReset called with credential: \(credential)")
        
        resolveCredential(credential) { resolvedEmail in
            print("[SimpleAuthView] resolveCredential returned (for reset): \(resolvedEmail ?? "nil")")
            
            guard let email = resolvedEmail, !email.isEmpty else {
                print("[SimpleAuthView] Could not resolve login credential for reset.")
                completion("Could not resolve login credential for password reset.")
                return
            }
            
            print("[SimpleAuthView] Attempting Firebase Auth password reset for: \(email)")
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    print("[SimpleAuthView] sendPasswordReset error: \(error.localizedDescription)")
                    completion(error.localizedDescription)
                } else {
                    print("[SimpleAuthView] Password reset email sent successfully.")
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Resolve Credential
    private func resolveCredential(_ credential: String, completion: @escaping (String?) -> Void) {
        print("[SimpleAuthView] resolveCredential called with: \(credential)")
        
        if credential.contains("@") {
            print("[SimpleAuthView] Credential is an email address. Returning it directly.")
            completion(credential)
            return
        }
        
        print("[SimpleAuthView] Checking Firestore for username or phone match.")
        let db = FirebaseManager.shared.db
        db.collection("users")
            .whereField("username", isEqualTo: credential)
            .getDocuments { snapshot, error in
                print("[SimpleAuthView] Firestore username query completed.")
                
                if let error = error {
                    print("[SimpleAuthView] Error by username: \(error.localizedDescription)")
                    completion("Error by username: \(error.localizedDescription)")
                    return
                }
                
                if let docs = snapshot?.documents, !docs.isEmpty,
                   let email = docs[0].data()["email"] as? String {
                    print("[SimpleAuthView] Found username match. Resolved email: \(email)")
                    completion(email)
                } else {
                    print("[SimpleAuthView] No username match found. Checking phone.")
                    db.collection("users")
                        .whereField("phone", isEqualTo: credential)
                        .getDocuments { snap2, err2 in
                            print("[SimpleAuthView] Firestore phone query completed.")
                            
                            if let err2 = err2 {
                                print("[SimpleAuthView] Error by phone: \(err2.localizedDescription)")
                                completion("Error by phone: \(err2.localizedDescription)")
                                return
                            }
                            
                            if let docs2 = snap2?.documents, !docs2.isEmpty,
                               let email2 = docs2[0].data()["email"] as? String {
                                print("[SimpleAuthView] Found phone match. Resolved email: \(email2)")
                                completion(email2)
                            } else {
                                print("[SimpleAuthView] No phone match found. Returning nil.")
                                completion(nil)
                            }
                        }
                }
            }
    }
}
