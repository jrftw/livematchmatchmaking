//
//  SignInView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Modern sign-in screen with dynamic gradient background
//  allowing user to log in or sign up.
//
import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var credential = "" // Can be email, phone, or username
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
                    AuthManager.shared.signIn(email: credential, password: password) { result in
                        switch result {
                        case .failure(let err):
                            errorMessage = err.localizedDescription
                            showingError = true
                        case .success:
                            break
                        }
                    }
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
}
