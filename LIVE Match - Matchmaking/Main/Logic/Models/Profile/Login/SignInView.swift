// MARK: - SignInView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows switching to UniversalSignUpView with a selectedScreen binding.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignInView: View {
    // MARK: - Environment & Bindings
    @Environment(\.colorScheme) private var colorScheme
    
    // Pass in a binding for the MainScreen so we can jump to .profile if desired
    @Binding var selectedScreen: MainScreen
    
    // MARK: - State
    @State private var credential = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // MARK: - Init
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
        let _ = print("[SignInView] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[SignInView] body invoked.")
        
        ZStack {
            let _ = print("[SignInView] Applying background gradient.")
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                topSection()
                credentialFields()
                actionButtons()
            }
            .padding()
            .alert(isPresented: $showingError) {
                let _ = print("[SignInView] Presenting error alert => \(errorMessage)")
                return Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Present UniversalSignUpView in a sheet.
            // Pass in selectedScreen so user can be sent to .profile upon creation.
            .sheet(isPresented: $showSignUp) {
                let _ = print("[SignInView] Presenting SignUpView sheet.")
                UniversalSignUpView(selectedScreen: $selectedScreen)
            }
        }
    }
}

// MARK: - Subviews
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension SignInView {
    private var backgroundGradient: LinearGradient {
        let _ = print("[SignInView] backgroundGradient computed => colorScheme: \(colorScheme)")
        
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
    
    private func topSection() -> some View {
        let _ = print("[SignInView] topSection invoked.")
        return Text("Log In or Sign Up").font(.largeTitle)
    }
    
    private func credentialFields() -> some View {
        let _ = print("[SignInView] credentialFields invoked.")
        
        return VStack(spacing: 16) {
            TextField("Email / Phone / Username", text: $credential)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        }
    }
    
    private func actionButtons() -> some View {
        let _ = print("[SignInView] actionButtons invoked.")
        
        return VStack(spacing: 12) {
            Button("Log In") {
                let _ = print("[SignInView] 'Log In' tapped => signInAction.")
                signInAction()
            }
            .font(.headline)
            .padding(.vertical, 8)
            
            Button("Sign Up") {
                let _ = print("[SignInView] 'Sign Up' tapped => showSignUp = true.")
                showSignUp = true
            }
            .font(.headline)
            .padding(.vertical, 5)
        }
    }
}

// MARK: - Sign In Logic
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension SignInView {
    private func signInAction() {
        let _ = print("[SignInView] signInAction called => credential: \(credential)")
        
        resolveCredential(credential) { resolvedEmail in
            let _ = print("[SignInView] resolveCredential completion => \(resolvedEmail ?? "nil")")
            
            guard let email = resolvedEmail, !email.isEmpty else {
                let _ = print("[SignInView] Could not resolve credential => error.")
                errorMessage = "Could not resolve login credential."
                showingError = true
                return
            }
            
            let _ = print("[SignInView] AuthManager signIn => \(email)")
            AuthManager.shared.signIn(email: email, password: password) { result in
                switch result {
                case .failure(let err):
                    let _ = print("[SignInView] signIn failed => \(err.localizedDescription)")
                    errorMessage = err.localizedDescription
                    showingError = true
                case .success:
                    let _ = print("[SignInView] signIn succeeded.")
                    // Optionally go to profile on success
                    self.selectedScreen = .profile
                }
            }
        }
    }
    
    /// Interprets the credential as email, username, or phone, returning an email if found
    private func resolveCredential(_ credential: String, completion: @escaping (String?) -> Void) {
        let _ = print("[SignInView] resolveCredential => \(credential)")
        
        // If '@' is present, assume it's an email
        if credential.contains("@") {
            let _ = print("[SignInView] '@' detected => using credential as email.")
            completion(credential)
            return
        }
        
        let db = Firestore.firestore()
        let _ = print("[SignInView] Checking Firestore => username => \(credential)")
        
        db.collection("users")
            .whereField("username", isEqualTo: credential)
            .getDocuments { snapshot, error in
                let _ = print("[SignInView] username query completed.")
                
                if let error = error {
                    let _ = print("[SignInView] Error => \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let docs = snapshot?.documents, !docs.isEmpty,
                   let email = docs[0].data()["email"] as? String {
                    let _ = print("[SignInView] Username match => \(email)")
                    completion(email)
                } else {
                    let _ = print("[SignInView] No username match => checking phone => \(credential)")
                    
                    db.collection("users")
                        .whereField("phone", isEqualTo: credential)
                        .getDocuments { snap2, err2 in
                            let _ = print("[SignInView] phone query completed.")
                            
                            if let err2 = err2 {
                                let _ = print("[SignInView] Error => \(err2.localizedDescription)")
                                completion(nil)
                                return
                            }
                            
                            if let docs2 = snap2?.documents, !docs2.isEmpty,
                               let email2 = docs2[0].data()["email"] as? String {
                                let _ = print("[SignInView] Phone match => \(email2)")
                                completion(email2)
                            } else {
                                let _ = print("[SignInView] No phone match => returning nil.")
                                completion(nil)
                            }
                        }
                }
            }
    }
}
